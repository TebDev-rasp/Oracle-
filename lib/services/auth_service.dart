import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final _logger = Logger('AuthService');

  Future<String> getUsername() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final snapshot = await _database.child('users').child(uid).child('username').get();
        if (snapshot.exists && snapshot.value != null) {
          return snapshot.value.toString();
        }
      }
      return 'User';
    } catch (e) {
      _logger.warning('Error fetching username', e);
      return 'User';
    }
  }

  bool isEmail(String input) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }

  Future<UserCredential> login(String emailOrUsername, String password) async {
    try {
      String email = emailOrUsername;
      
      if (!isEmail(emailOrUsername)) {
        email = await getEmailFromUsername(emailOrUsername);
      }

      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _logger.warning('Login error', e);
      rethrow;
    }
  }

  Future<UserCredential> register(String email, String password, String username) async {
    _logger.info('Starting registration process');
    
    // Input validation
    if (!isEmail(email)) {
      _logger.warning('Invalid email format');
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter a valid email address',
      );
    }

    // Check username format (you can modify these requirements)
    if (username.length < 3 || username.length > 20 || !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      throw FirebaseAuthException(
        code: 'invalid-username',
        message: 'Username must be 3-20 characters long and contain only letters, numbers, and underscores',
      );
    }

    try {
      // Check if username already exists
      final usernameSnapshot = await _database
          .child('usernames')
          .orderByChild('username')
          .equalTo(username)
          .get();

      if (usernameSnapshot.exists) {
        _logger.warning('Username already exists');
        throw FirebaseAuthException(
          code: 'username-exists',
          message: 'This username is already taken',
        );
      }

      _logger.info('Username check passed');

      // Create authentication account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _logger.info('Auth account created');

      // Store username mapping
      await _database.child('usernames').child(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': ServerValue.timestamp,
      });

      // Store user data
      await _database.child('users').child(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': ServerValue.timestamp,
        'profile': {
          'displayName': username,
          'photoURL': ''
        }
      });

      _logger.info('User data stored successfully');
      return userCredential;
    } catch (e) {
      _logger.severe('Registration error', e);
      rethrow;
    }
  }

  Future<String> getEmailFromUsername(String username) async {
    try {
      final usernameSnapshot = await _database
          .child('usernames')
          .orderByChild('username')
          .equalTo(username)
          .get();

      if (!usernameSnapshot.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this username',
        );
      }

      final Map<dynamic, dynamic> data = usernameSnapshot.value as Map;
      final Map<dynamic, dynamic> userEntry = data.values.first as Map;
      return userEntry['email'] as String;
    } catch (e) {
      _logger.warning('Error getting email from username', e);
      rethrow;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update profile in users node
        final updates = <String, dynamic>{};
        if (displayName != null) {
          updates['displayName'] = displayName;
        }
        if (photoURL != null) {
          updates['photoURL'] = photoURL;
        }

        if (updates.isNotEmpty) {
          await _database
              .child('users')
              .child(user.uid)
              .child('profile')
              .update(updates);
        }
      }
    } catch (e) {
      _logger.warning('Error updating profile', e);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.info('Password reset email sent');
    } catch (e) {
      _logger.warning('Password reset error', e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _logger.info('User signed out successfully');
    } catch (e) {
      _logger.warning('Sign out error', e);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data
        await _database.child('users').child(user.uid).remove();
        // Delete username mapping
        await _database.child('usernames').child(user.uid).remove();
        // Delete authentication account
        await user.delete();
        
        _logger.info('Account deleted successfully');
      }
    } catch (e) {
      _logger.severe('Delete account error', e);
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
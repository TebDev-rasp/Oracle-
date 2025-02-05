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
        final snapshot = await _database.child('usernames').child(uid).get();
        if (snapshot.exists) {
          final data = snapshot.value as Map;
          return data['username'] as String;
        }
      }
      return 'User';
    } catch (e) {
      _logger.warning('Error fetching username', e);
      return 'User';
    }
  }

  bool isEmail(String input) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(input);
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
    
    final usernameCheck = await _database
        .child('usernames')
        .orderByChild('username')
        .equalTo(username)
        .get();

    if (usernameCheck.exists) {
      _logger.warning('Username already exists');
      throw FirebaseAuthException(
        code: 'username-exists',
        message: 'This username is already taken',
      );
    }

    _logger.info('Username check passed');

    if (!isEmail(email)) {
      _logger.warning('Email validation failed');
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter a valid email address',
      );
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _logger.info('Auth account created');

      await _database.child('usernames').child(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': ServerValue.timestamp,
      });

      _logger.info('Username mapping stored');
      return userCredential;
    } catch (e) {
      _logger.severe('Registration error', e);
      rethrow;
    }
  }

  Future<String> getEmailFromUsername(String username) async {
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

    final userData = (usernameSnapshot.value as Map).values.first as Map;
    return userData['email'] as String;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
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
        await _database.child('usernames').child(user.uid).remove();
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
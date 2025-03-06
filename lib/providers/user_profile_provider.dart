import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import '../services/image_service.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class UserProfileProvider with ChangeNotifier {
  final _logger = Logger('UserProfileProvider');
  String _username = 'User';
  File? _profileImage;
  bool _isInitialized = false;
  final _database = FirebaseDatabase.instance.ref();
  final _authService = AuthService();

  String get username => _username;
  File? get profileImage => _profileImage;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  Future<void> initializeProfile(String userId) async {
    if (_isInitialized) return;
    
    try {
      final snapshot = await _database.child('usernames').child(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map;
        _username = data['username'] as String;
        notifyListeners();
      }

      final imageService = ImageService();
      final base64Image = await imageService.getImageBase64(userId);
      
      if (base64Image != null) {
        final appDir = await getApplicationDocumentsDirectory(); // Changed from getTemporaryDirectory
        final tempFile = File('${appDir.path}/profile_image_$userId.jpg');
        await tempFile.writeAsBytes(base64Decode(base64Image));
        _profileImage = tempFile;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _logger.warning('Error initializing profile', e);
      _isInitialized = true; // Set to true even on error to prevent repeated fetching
      notifyListeners();
      // Reset to default state on error
      reset();
    }
  }

  Future<void> loadUserProfile() async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        final username = await _authService.getUsername();
        _username = username;
        _isInitialized = true;
        notifyListeners();
      } catch (e) {
        _logger.warning('Error loading user profile', e);
        reset();
      }
    }
  }

  Future<void> loadSavedProfileImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      _profileImage = file;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(File newImage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Save to permanent storage
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_image_${user.uid}.jpg';
      final permanentFile = File('${appDir.path}/$fileName');
      
      // Copy the new image to permanent storage
      await newImage.copy(permanentFile.path);
      
      // Save the path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_${user.uid}', permanentFile.path);
      
      _profileImage = permanentFile;
      notifyListeners();
    } catch (e) {
      developer.log('Error updating profile image: $e');
    }
  }

  Future<void> clearProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Remove from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_${user.uid}');

      // Delete the file if it exists
      if (_profileImage != null && await _profileImage!.exists()) {
        await _profileImage!.delete();
      }

      _profileImage = null;
      notifyListeners();
    } catch (e) {
      _logger.warning('Error clearing profile image', e);
    }
  }

  void updateUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void reset() {
    _username = 'User';  // Changed from null to default value
    _profileImage = null;
    _isInitialized = false;
    notifyListeners();
  }
}
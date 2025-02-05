import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import '../services/image_service.dart';

class UserProfileProvider with ChangeNotifier {
  final _logger = Logger('UserProfileProvider');
  String? _username;
  File? _profileImage;
  bool _isInitialized = false;
  final _database = FirebaseDatabase.instance.ref();

  String? get username => _username;
  File? get profileImage => _profileImage;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  Future<void> initializeProfile(String userId) async {
    if (_isInitialized) return;
    
    try {
      final snapshot = await _database.child('usernames').child(userId).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        _username = data['username'] as String;
        notifyListeners();
      }

      final imageService = ImageService();
      final base64Image = await imageService.getImageBase64(userId);
      
      if (base64Image != null) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/profile_image_$userId.jpg');
        await tempFile.writeAsBytes(base64Decode(base64Image));
        _profileImage = tempFile;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _logger.warning('Error initializing profile', e);
    }
  }

  void updateUsername(String? newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void updateProfileImage(File? newImage) {
    _profileImage = newImage;
    notifyListeners();
  }

  void reset() {
    _username = null;
    _profileImage = null;
    _isInitialized = false;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isNewGoogleUser = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isNewGoogleUser => _isNewGoogleUser;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Initialize
  Future<void> initUser() async {
    if (_authService.currentUser != null) {
      await loadUser(_authService.currentUser!.uid);
    }
  }

  // Load user
  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _databaseService.getUser(uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String college,
    required String major,
    required String year,
    required String bio,
    required List<String> interests,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        age: age,
        gender: gender,
        college: college,
        major: major,
        year: year,
        bio: bio,
        interests: interests,
      );

      if (_authService.currentUser != null) {
        await loadUser(_authService.currentUser!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with email
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email: email, password: password);

      if (_authService.currentUser != null) {
        await loadUser(_authService.currentUser!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    _isNewGoogleUser = false;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential?.user != null) {
        // Check if profile is complete
        bool isComplete =
            await _authService.isProfileComplete(credential!.user!.uid);
        _isNewGoogleUser = !isComplete;

        await loadUser(credential.user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Complete Google profile
  Future<bool> completeProfile({
    required int age,
    required String gender,
    required String college,
    required String major,
    required String year,
    required String bio,
    required List<String> interests,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateUser(_currentUser!.uid, {
        'age': age,
        'gender': gender,
        'college': college,
        'major': major,
        'year': year,
        'bio': bio,
        'interests': interests,
      });

      await loadUser(_currentUser!.uid);
      _isNewGoogleUser = false;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _isNewGoogleUser = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateUser(_currentUser!.uid, data);
      await loadUser(_currentUser!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update profile photo
  Future<bool> updateProfilePhoto(String photoUrl) async {
    return await updateProfile({'profilePicUrl': photoUrl});
  }

  // Add photo to gallery
  Future<bool> addPhoto(String photoUrl) async {
    if (_currentUser == null) return false;

    List<String> photos = List.from(_currentUser!.photoUrls);
    photos.add(photoUrl);

    return await updateProfile({'photoUrls': photos});
  }

  // Remove photo from gallery
  Future<bool> removePhoto(String photoUrl) async {
    if (_currentUser == null) return false;

    List<String> photos = List.from(_currentUser!.photoUrls);
    photos.remove(photoUrl);

    return await updateProfile({'photoUrls': photos});
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
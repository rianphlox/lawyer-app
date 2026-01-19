import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/user_role.dart';

class MockAuthService {
  final StreamController<AppUser?> _authStateController = StreamController<AppUser?>();
  AppUser? _currentUser;

  // Current user stream
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  // Current user
  AppUser? get currentUser => _currentUser;

  // Mock users for demo
  static final List<AppUser> _mockUsers = [
    AppUser(
      id: 'client1',
      email: 'client@test.com',
      name: 'John Client',
      role: UserRole.client,
      phoneNumber: '+1234567890',
      location: 'New York, NY',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
      isVerified: true,
      isActive: true,
    ),
    AppUser(
      id: 'lawyer1',
      email: 'lawyer@test.com',
      name: 'Jane Lawyer',
      role: UserRole.seniorLawyer,
      phoneNumber: '+0987654321',
      location: 'Los Angeles, CA',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastLoginAt: DateTime.now(),
      isVerified: true,
      isActive: true,
    ),
  ];

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
    String? location,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user already exists
    if (_mockUsers.any((user) => user.email == email)) {
      throw 'An account already exists with this email address.';
    }

    // Create new user
    final newUser = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      phoneNumber: phoneNumber,
      location: location,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isVerified: false,
      isActive: true,
    );

    _mockUsers.add(newUser);
    _currentUser = newUser;
    await _saveCurrentUser();
    _authStateController.add(_currentUser);

    return newUser;
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Find user by email
    final user = _mockUsers.firstWhere(
      (user) => user.email == email,
      orElse: () => throw 'No user found with this email address.',
    );

    // Mock password validation (in real app, this would be secure)
    if (password.length < 6) {
      throw 'Invalid password.';
    }

    // Update last login
    final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
    final index = _mockUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _mockUsers[index] = updatedUser;
    }

    _currentUser = updatedUser;
    await _saveCurrentUser();
    _authStateController.add(_currentUser);

    return updatedUser;
  }

  // Get user profile
  Future<AppUser?> getUserProfile(String uid) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      return _mockUsers.firstWhere((user) => user.id == uid);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phoneNumber,
    String? location,
    String? profileImageUrl,
    bool? isVerified,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockUsers.indexWhere((user) => user.id == uid);
    if (index != -1) {
      final user = _mockUsers[index];
      final updatedUser = user.copyWith(
        name: name ?? user.name,
        phoneNumber: phoneNumber ?? user.phoneNumber,
        location: location ?? user.location,
        profileImageUrl: profileImageUrl ?? user.profileImageUrl,
        isVerified: isVerified ?? user.isVerified,
        metadata: metadata ?? user.metadata,
      );
      _mockUsers[index] = updatedUser;

      if (_currentUser?.id == uid) {
        _currentUser = updatedUser;
        _authStateController.add(_currentUser);
      }
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    // Check if user exists
    if (!_mockUsers.any((user) => user.email == email)) {
      throw 'No user found with this email address.';
    }

    // In a real app, this would send an actual email
    // For demo purposes, we'll just simulate success
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock email verification sent
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser?.isVerified ?? false;
  }

  // Sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    await _saveCurrentUser();
    _authStateController.add(null);
  }

  // Delete account
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser != null) {
      _mockUsers.removeWhere((user) => user.id == _currentUser!.id);
      _currentUser = null;
      await _saveCurrentUser();
      _authStateController.add(null);
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock password validation
    if (currentPassword.length < 6) {
      throw 'Current password is invalid.';
    }

    if (newPassword.length < 6) {
      throw 'New password is too weak. Please choose a stronger password.';
    }

    // In a real app, this would update the password securely
  }

  // Check if user exists with email
  Future<bool> userExistsWithEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers.any((user) => user.email == email);
  }

  // Initialize with saved user if exists
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('current_user_id');

    if (savedUserId != null) {
      try {
        final user = _mockUsers.firstWhere(
          (user) => user.id == savedUserId,
        );
        _currentUser = user;
        _authStateController.add(_currentUser);
      } catch (e) {
        // Saved user not found, clear saved data
        await prefs.remove('current_user_id');
      }
    }
  }

  // Save current user ID for persistence
  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('current_user_id', _currentUser!.id);
    } else {
      await prefs.remove('current_user_id');
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
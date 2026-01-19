import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/mock_auth_service.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../core/constants.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final MockAuthService _authService = MockAuthService();

  AuthStatus _status = AuthStatus.uninitialized;
  AppUser? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isLawyer => _user?.role.isLawyer ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    // Initialize the mock auth service
    await _authService.initialize();

    _authService.authStateChanges.listen((AppUser? user) async {
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _saveUserRole(user.role);
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
        await _clearUserRole();
      }
      notifyListeners();
    });
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
    String? location,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
        location: location,
      );

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _saveUserRole(role);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _saveUserRole(user.role);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      await _clearUserRole();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: $e');
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? location,
    String? profileImageUrl,
    bool? isVerified,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_user != null) {
        await _authService.updateUserProfile(
          uid: _user!.id,
          name: name,
          phoneNumber: phoneNumber,
          location: location,
          profileImageUrl: profileImageUrl,
          isVerified: isVerified,
          metadata: metadata,
        );

        // Update local user data
        _user = _user!.copyWith(
          name: name ?? _user!.name,
          phoneNumber: phoneNumber ?? _user!.phoneNumber,
          location: location ?? _user!.location,
          profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
          isVerified: isVerified ?? _user!.isVerified,
          metadata: metadata ?? _user!.metadata,
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Check email verification
  Future<bool> checkEmailVerification() async {
    try {
      final isVerified = await _authService.isEmailVerified();
      if (isVerified && _user != null) {
        await updateProfile(isVerified: true);
      }
      return isVerified;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount();
      _user = null;
      _status = AuthStatus.unauthenticated;
      await _clearUserRole();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user exists
  Future<bool> userExists(String email) async {
    return await _authService.userExistsWithEmail(email);
  }

  // Save user role to SharedPreferences
  Future<void> _saveUserRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userRoleKey, role.name);
  }

  // Clear user role from SharedPreferences
  Future<void> _clearUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userRoleKey);
  }

  // Get saved user role
  Future<UserRole?> getSavedUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString(AppConstants.userRoleKey);
    if (roleName != null) {
      return UserRole.values.firstWhere(
        (role) => role.name == roleName,
        orElse: () => UserRole.client,
      );
    }
    return null;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
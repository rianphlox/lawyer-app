import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../models/user_role.dart';
import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
    String? location,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Create user profile
        final appUser = AppUser(
          id: user.uid,
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

        // Save user to Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(appUser.toJson());

        // Update display name
        await user.updateDisplayName(name);

        return appUser;
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Update last login time
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({
          'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        });

        return await getUserProfile(user.uid);
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  // Get user profile
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson(doc.data()!);
      }
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
    return null;
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
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (location != null) updates['location'] = location;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (isVerified != null) updates['isVerified'] = isVerified;
      if (metadata != null) updates['metadata'] = metadata;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .update(updates);
      }

      // Update display name in Firebase Auth if provided
      if (name != null && currentUser != null) {
        await currentUser!.updateDisplayName(name);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .delete();

        // Delete Firebase Auth account
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if user exists with email
  Future<bool> userExistsWithEmail(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Handle authentication exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Invalid password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'requires-recent-login':
          return 'Please log in again to complete this action.';
        default:
          return 'Authentication failed: ${e.message}';
      }
    }
    return 'An unexpected error occurred: $e';
  }
}
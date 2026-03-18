import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Register a new user with a specific role
  Future<User?> registerUser({
    required String email,
    required String password,
    required String displayName,
    required String role, // 'USER' or 'SERVICE_PROVIDER'
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        throw 'Registration failed: All fields are required';
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final newUser = userCredential.user;
      if (newUser != null) {
        await newUser.updateDisplayName(displayName);
        // Save user role in Firestore
        await _firestoreService.createUserProfile(
          uid: newUser.uid,
          email: email,
          displayName: displayName,
          role: role,
        );
        return newUser;
      } else {
        throw 'Registration failed: User account could not be initialized';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      return Future.error('Registration internal error: ${e.toString()}');
    }
  }

  /// Login user
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get the role of the current user
  Future<String?> getUserRole(String uid) async {
    try {
      final userData = await _firestoreService.getUserProfile(uid);
      return userData['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    await _firebaseAuth.signOut();
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'User account has been disabled.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

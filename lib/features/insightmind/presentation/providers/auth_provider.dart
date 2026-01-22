import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider untuk Auth State (Mendeteksi user login/logout)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// 2. Controller untuk Aksi (Login, Register, Reset)
final authControllerProvider = Provider((ref) => AuthController());

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- LOGIN ---
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // --- REGISTER ---
  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update Nama User
      await result.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // --- RESET PASSWORD ---
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // --- LOGOUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper Error Message
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'Email tidak ditemukan.';
      case 'wrong-password': return 'Password salah.';
      case 'email-already-in-use': return 'Email sudah terdaftar.';
      case 'invalid-email': return 'Format email salah.';
      case 'weak-password': return 'Password terlalu lemah.';
      default: return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
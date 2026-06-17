import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream listening dynamically to user auth updates
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user registered with this email account.';
      case 'wrong-password':
        return 'Incorrect credential password. Try again.';
      case 'email-already-in-use':
        return 'This email address is already bound to another profile.';
      case 'weak-password':
        return 'The chosen password configuration is too weak.';
      case 'invalid-email':
        return 'The formatted text format is not a valid email address.';
      default:
        return e.message ?? 'An unexpected authentication exception transpired.';
    }
  }
}
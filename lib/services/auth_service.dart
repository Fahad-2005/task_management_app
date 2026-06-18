import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // Signs up the user and saves their profile metadata straight to Firestore
  Future<UserCredential> signUpWithEmailAndPassword(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null) {
        // Save user details to Cloud Firestore
        await _db.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Streams real-time profile documents directly from Cloud Firestore
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
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
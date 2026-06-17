import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management_app/services/auth_service.dart';
import 'package:task_management_app/services/api_service.dart';
import 'package:task_management_app/models/user_profile.dart';

// Single-instance system service reference declarations
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Auth stream state monitor provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Future network pipeline consumer monitoring REST operations
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.watch(apiServiceProvider).fetchUserProfile();
});
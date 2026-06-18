import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management_app/services/auth_service.dart';
import 'package:task_management_app/services/api_service.dart';
import 'package:task_management_app/services/task_storage.dart';
import 'package:task_management_app/models/user_profile.dart';
import 'package:task_management_app/models/task.dart';

// Service providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final taskStorageProvider = Provider<TaskStorage>((ref) => TaskStorage());

// Auth stream state monitor provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// JSONPlaceholder REST API provider
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.watch(apiServiceProvider).fetchUserProfile();
});

// Dynamic Firestore Cloud Profile Sync Stream Provider
final firestoreUserProvider = StreamProvider.family<DocumentSnapshot<Map<String, dynamic>>, String>((ref, uid) {
  return ref.watch(authServiceProvider).watchUserProfile(uid);
});

// Riverpod Notifier managing our active task lists state independently of UI code loops
class TaskNotifier extends Notifier<List<Task>> {
  late final TaskStorage _storage;

  @override
  List<Task> build() {
    _storage = ref.watch(taskStorageProvider);
    _loadInitialTasks();
    return [];
  }

  Future<void> _loadInitialTasks() async {
    final tasks = await _storage.loadTasks();
    state = tasks;
  }

  Future<void> addTask(String title) async {
    state = [...state, Task(title: title)];
    await _storage.saveTasks(state);
  }

  Future<void> toggleTask(int index) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(isCompleted: !state[i].isCompleted) else state[i]
    ];
    await _storage.saveTasks(state);
  }

  Future<void> deleteTask(int index) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
    await _storage.saveTasks(state);
  }
}

// Global provider declaration accessing our business state pipeline
final taskListProvider = NotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});
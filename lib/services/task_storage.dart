import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/models/task.dart';

class TaskStorage {
  static const _tasksKey = 'saved_tasks';
  static const _userNameKey = 'user_profile_name';

  // Save name string to local cache
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // Read name string from local cache
  Future<String> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'New User';
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_tasksKey) ?? [];
    return stored.map(_decodeTask).whereType<Task>().toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tasks.map(_encodeTask).toList();
    await prefs.setStringList(_tasksKey, encoded);
  }

  String _encodeTask(Task task) {
    final completedFlag = task.isCompleted ? '1' : '0';
    return '$completedFlag|${task.title}';
  }

  Task? _decodeTask(String value) {
    final separatorIndex = value.indexOf('|');
    if (separatorIndex <= 0 || separatorIndex >= value.length - 1) {
      return null;
    }

    final completedFlag = value.substring(0, separatorIndex);
    final title = value.substring(separatorIndex + 1).trim();
    if (title.isEmpty) {
      return null;
    }

    return Task(title: title, isCompleted: completedFlag == '1');
  }
}
import 'package:flutter/material.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/services/task_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.email});

  final String email;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskStorage = TaskStorage();
  final _taskController = TextEditingController();
  final List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskStorage.loadTasks();
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks
        ..clear()
        ..addAll(tasks);
      _isLoading = false;
    });
  }

  Future<void> _persistTasks() async {
    await _taskStorage.saveTasks(_tasks);
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      return;
    }

    setState(() {
      _tasks.add(Task(title: title));
      _taskController.clear();
    });
    _persistTasks();
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
    });
    _persistTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _persistTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Welcome, ${widget.email}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add task',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tasks.isEmpty
                    ? const Center(
                      child: Text('No tasks yet. Add your first task above.'),
                    )
                    : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Dismissible(
                          key: ValueKey('${task.title}-$index'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteTask(index),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) => _toggleTask(index),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration:
                                    task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteTask(index),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

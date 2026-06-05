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
  final List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
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

  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_task),
              SizedBox(width: 8),
              Text('Add Task'),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Task title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_note),
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, controller.text),
              icon: const Icon(Icons.check),
              label: const Text('Add'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    final trimmedTitle = title?.trim() ?? '';
    if (trimmedTitle.isEmpty) {
      return;
    }

    setState(() {
      _tasks.add(Task(title: trimmedTitle));
    });
    await _persistTasks();

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Task added'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
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

  Future<void> _confirmDeleteTask(int index) async {
    final task = _tasks[index];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded),
              SizedBox(width: 8),
              Text('Delete Task'),
            ],
          ),
          content: Text('Remove "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteTask(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((task) => task.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist_rtl),
            SizedBox(width: 8),
            Text('Task Manager'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add task',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        widget.email,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of ${_tasks.length} tasks completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tasks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          const Text('Tap + in the app bar to add a task'),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey('$index-${task.title}'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteTask(index),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_sweep,
                                color: Colors.white,
                              ),
                            ),
                            child: Card(
                              elevation: 0,
                              color:
                                  task.isCompleted
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest
                                      : null,
                              child: ListTile(
                                leading: IconButton(
                                  onPressed: () => _toggleTask(index),
                                  icon: Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color:
                                        task.isCompleted
                                            ? Colors.green
                                            : Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                  ),
                                  tooltip:
                                      task.isCompleted
                                          ? 'Mark incomplete'
                                          : 'Mark complete',
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration:
                                        task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                    color:
                                        task.isCompleted
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.outline
                                            : null,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(
                                      task.isCompleted
                                          ? Icons.task_alt
                                          : Icons.pending_actions,
                                      size: 16,
                                      color:
                                          task.isCompleted
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.isCompleted
                                          ? 'Completed'
                                          : 'Pending',
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () => _confirmDeleteTask(index),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete task',
                                ),
                              ),
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

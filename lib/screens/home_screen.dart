import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/providers/app_providers.dart';
import 'package:task_management_app/screens/user_profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch Riverpod State pipelines directly[cite: 2]
    final tasks = ref.watch(taskListProvider);
    final firebaseUser = ref.watch(authServiceProvider).currentUser;

    // Resolve user's cloud-saved name dynamically with an email fallback[cite: 2]
    String userGreetingIdentity = email;
    if (firebaseUser != null) {
      final cloudUserDoc = ref.watch(firestoreUserProvider(firebaseUser.uid));
      cloudUserDoc.whenData((doc) {
        if (doc.exists && doc.data()?['name'] != null) {
          userGreetingIdentity = doc.data()!['name'];
        }
      });
    }

    final completedCount = tasks.where((task) => task.isCompleted).length;

    void showAddTaskDialog() async {
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
      if (trimmedTitle.isEmpty) return;

      // Dispatch changes to global provider framework[cite: 2]
      ref.read(taskListProvider.notifier).addTask(trimmedTitle);
    }

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            },
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'View Profile',
          ),
          IconButton(
            onPressed: showAddTaskDialog,
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
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
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
                        userGreetingIdentity,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of ${tasks.length} tasks completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
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
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ValueKey('$index-${task.title}'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => ref.read(taskListProvider.notifier).deleteTask(index),
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
                            color: task.isCompleted
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : null,
                            child: ListTile(
                              leading: IconButton(
                                onPressed: () => ref.read(taskListProvider.notifier).toggleTask(index),
                                icon: Icon(
                                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: task.isCompleted
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.outline,
                                ),
                                tooltip: task.isCompleted ? 'Mark incomplete' : 'Mark complete',
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  color: task.isCompleted ? Theme.of(context).colorScheme.outline : null,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    task.isCompleted ? Icons.task_alt : Icons.pending_actions,
                                    size: 16,
                                    color: task.isCompleted ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(task.isCompleted ? 'Completed' : 'Pending'),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Task'),
                                      content: Text('Remove "${task.title}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (shouldDelete == true) {
                                    ref.read(taskListProvider.notifier).deleteTask(index);
                                  }
                                },
                                icon: const Icon(Icons.delete_outline),
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
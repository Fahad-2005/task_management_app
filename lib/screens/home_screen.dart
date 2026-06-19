import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/providers/app_providers.dart';
import 'package:task_management_app/screens/user_profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Route _createAnimatedProfileRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const UserProfileScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); 
      const end = Offset.zero;
      const curve = Curves.easeOutExpo; // Changed to the web-safe naming configuration

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

  void _showAdvancedAddTaskSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.rocket_launch, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'New Task Objective',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'What needs to be accomplished?',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    ref.read(taskListProvider.notifier).addTask(text);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Deploy Objective', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);
    final firebaseUser = ref.watch(authServiceProvider).currentUser;

    String userName = widget.email;
    if (firebaseUser != null) {
      final cloudUserDoc = ref.watch(firestoreUserProvider(firebaseUser.uid));
      cloudUserDoc.whenData((doc) {
        if (doc.exists && doc.data()?['name'] != null) {
          userName = doc.data()!['name'];
        }
      });
    }

    final completedCount = tasks.where((task) => task.isCompleted).length;
    final double completionPercentage = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Elegant premium off-white canvas
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Workspace',
          style: TextStyle(
            color: const Color(0xFF0F172A), // Premium Slate 900
            fontWeight: FontWeight.w800, 
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () => Navigator.of(context).push(_createAnimatedProfileRoute()),
              icon: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.person, color: Colors.blue.shade800),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdvancedAddTaskSheet,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Objective', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Stats Dashboard Summary Card Panel
          AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _staggerController,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
                    CurvedAnimation(parent: _staggerController, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)], // Slate 900 to Slate 800
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COMMAND CENTER', style: TextStyle(color: Colors.blue.shade400, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11)),
                        const SizedBox(height: 6),
                        Text('Welcome, $userName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 8),
                        Text('$completedCount of ${tasks.length} objectives secured', style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)), // Slate 300
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: completionPercentage,
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFF334155), // Slate 700
                          color: Colors.blue.shade400,
                        ),
                      ),
                      Text(
                        '${(completionPercentage * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              'ACTIVE OBJECTIVES',
              style: TextStyle(
                color: const Color(0xFF64748B), // Slate 500
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.1, 
                fontSize: 12,
              ),
            ),
          ),

          // Main Task Grid/List Interface Layout Container
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 72, color: Color(0xFFCBD5E1)), // Slate 300
                        const SizedBox(height: 16),
                        Text('All clear arrays.', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)), // Slate 900
                        const SizedBox(height: 4),
                        Text('No active pending objectives found.', style: TextStyle(color: Color(0xFF94A3B8))), // Slate 400
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: task.isCompleted ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.03), // Slate 900 alpha
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: InkWell(
                            onTap: () => ref.read(taskListProvider.notifier).toggleTask(index),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: task.isCompleted ? Colors.blue.shade50 : Colors.transparent,
                                border: Border.all(
                                  color: task.isCompleted ? Colors.blue : const Color(0xFFCBD5E1), // Slate 300
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 18,
                                color: task.isCompleted ? Colors.blue : Colors.transparent,
                              ),
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B), // Slate 400 vs Slate 800
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                            onPressed: () => ref.read(taskListProvider.notifier).deleteTask(index),
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
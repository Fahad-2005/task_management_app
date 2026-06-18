import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/providers/app_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: firebaseUser == null
              ? const Text('No Authenticated Session Found')
              : ref.watch(firestoreUserProvider(firebaseUser.uid)).when(
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Failed to load user profile: $err'),
                    data: (snapshot) {
                      // Fetch name directly from the Firestore document record[cite: 2]
                      final String displayName = snapshot.data()?['name'] ?? 'App User';
                      final String displayEmail = snapshot.data()?['email'] ?? firebaseUser.email ?? 'No Email';
                      final fallbackAvatarUrl = 'https://robohash.org/${displayName.hashCode}.png?size=150x150';

                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                backgroundImage: NetworkImage(fallbackAvatarUrl),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                displayName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayEmail,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await ref.read(authServiceProvider).signOut();
                                  if (context.mounted) {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Sign Out Account'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ),
    );
  }
}
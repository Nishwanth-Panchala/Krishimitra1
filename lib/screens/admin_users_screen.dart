import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers/app_providers.dart';
import '../models/user_profile.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(registeredUserAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed: $err')),
          data: (auth) {
            if (auth == null) {
              return const Center(child: Text('No users registered yet.'));
            }

            final UserProfile profile = auth.profile;
            return ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registered User',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text('Name: ${profile.name}'),
                        const SizedBox(height: 6),
                        Text('Mobile: ${profile.mobileNumber}'),
                        const SizedBox(height: 6),
                        Text('State: ${profile.state}'),
                        const SizedBox(height: 6),
                        Text('Language: ${profile.language}'),
                        const SizedBox(height: 6),
                        Text('Soil Type: ${profile.soilType}'),
                        const SizedBox(height: 6),
                        Text('Acres: ${profile.numberOfAcres}'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: profile.cropTypes
                              .map((c) => Chip(label: Text(c)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


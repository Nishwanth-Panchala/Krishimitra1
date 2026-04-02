import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers/app_providers.dart';
import '../models/scheme.dart';
import '../widgets/scheme_editor_dialog.dart';

class AdminManageSchemesScreen extends ConsumerWidget {
  const AdminManageSchemesScreen({super.key});

  Future<void> _showEditor(BuildContext context, WidgetRef ref, {Scheme? initial}) async {
    final updated = await showDialog<Scheme>(
      context: context,
      builder: (_) => SchemeEditorDialog(initial: initial),
    );

    if (updated == null) return;

    final repo = ref.read(schemesRepositoryProvider);
    final current = await repo.fetchSchemesWithAdminOverrides();

    final next = <Scheme>[];
    final exists = current.any((s) => s.id == updated.id);
    if (exists) {
      next.addAll(current.map((s) => s.id == updated.id ? updated : s));
    } else {
      next.addAll(current);
      next.add(updated);
    }

    await repo.saveAllSchemes(next);
    ref.invalidate(schemesProvider);
  }

  Future<void> _deleteScheme(BuildContext context, WidgetRef ref, Scheme scheme) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Scheme'),
        content: Text('Are you sure you want to delete "${scheme.schemeName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final repo = ref.read(schemesRepositoryProvider);
    final current = await repo.fetchSchemesWithAdminOverrides();
    final next = current.where((s) => s.id != scheme.id).toList(growable: false);
    await repo.saveAllSchemes(next);
    ref.invalidate(schemesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemesAsync = ref.watch(schemesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Manage Schemes'),
        actions: [
          IconButton(
            tooltip: 'Go to Feedback',
            onPressed: () => context.go('/admin/feedback'),
            icon: const Icon(Icons.feedback),
          ),
          IconButton(
            tooltip: 'Go to Notifications',
            onPressed: () => context.go('/admin/notifications'),
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: schemesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load schemes: $err')),
          data: (schemes) {
            if (schemes.isEmpty) {
              return const Center(child: Text('No schemes available.'));
            }

            return ListView.separated(
              itemCount: schemes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                scheme.schemeName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _showEditor(context, ref, initial: scheme),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _deleteScheme(context, ref, scheme),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scheme.basicInfo,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Chip(
                              avatar: Icon(
                                scheme.schemeType == SchemeType.central
                                    ? Icons.account_balance
                                    : Icons.location_city,
                                size: 18,
                              ),
                              label: Text(
                                scheme.schemeType == SchemeType.central
                                    ? 'Central'
                                    : scheme.state.trim().isEmpty
                                        ? 'State'
                                        : scheme.state,
                              ),
                            ),
                            if (scheme.lastDate.trim().isNotEmpty)
                              Chip(
                                avatar: const Icon(Icons.date_range, size: 18),
                                label: Text('Last: ${scheme.lastDate}'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go(
                              '/scheme/${Uri.encodeComponent(scheme.id)}',
                            ),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        tooltip: 'Add Scheme',
        child: const Icon(Icons.add),
      ),
    );
  }
}


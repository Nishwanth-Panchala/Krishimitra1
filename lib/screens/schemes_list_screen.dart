import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers/app_providers.dart';
import '../models/auth_role.dart';
import '../models/scheme.dart';
import '../services/url_service.dart';
import '../widgets/scheme_card.dart';

class SchemesListScreen extends ConsumerWidget {
  final SchemeType filterType;
  final String title;

  const SchemesListScreen({
    super.key,
    required this.filterType,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemesAsync = ref.watch(schemesProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final roleAsync = ref.watch(authRoleProvider);

    final bookmarkedIds = bookmarksAsync.value ?? <String>{};
    final reminderIds = remindersAsync.value ?? <String>{};

    return Scaffold(
      appBar: AppBar(
        title: roleAsync.when(
          loading: () => Text(title),
          error: (_, __) => Text(title),
          data: (role) {
            if (role == AuthRole.admin) {
              return Text('Admin - $title');
            }
            return Text(title);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              context.go('/notifications');
            },
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            tooltip: 'Bookmarks',
            onPressed: () => context.go('/bookmarks'),
            icon: const Icon(Icons.bookmark),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  ref.invalidate(schemesProvider);
                },
                icon: const Icon(Icons.download),
                label: const Text('Fetch Schemes'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: schemesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Center(
                  child: Text('Failed to load schemes: $err'),
                ),
                data: (schemes) {
                  final farmerState = profileAsync.valueOrNull?.state ?? '';
                  var filtered =
                      schemes.where((s) => s.schemeType == filterType).toList();
                  if (filterType == SchemeType.state) {
                    filtered = filtered
                        .where((s) => s.matchesFarmerState(farmerState))
                        .toList();
                  }
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        filterType == SchemeType.state &&
                                farmerState.trim().isNotEmpty
                            ? 'No state schemes found for $farmerState. '
                                'Check your state in Account or try Fetch Schemes.'
                            : 'No schemes found for this filter.',
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final scheme = filtered[index];
                      return SchemeCard(
                        scheme: scheme,
                        isBookmarked: bookmarkedIds.contains(scheme.id),
                        isReminded: reminderIds.contains(scheme.id),
                        onTap: () => context.go(
                          '/scheme/${Uri.encodeComponent(scheme.id)}',
                        ),
                        onApply: () async {
                          final link = scheme.applicationLink.trim();
                          if (link.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No apply link available.')),
                            );
                            return;
                          }
                          try {
                            await UrlService.openUrl(link);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        onToggleBookmark: () async {
                          await ref
                              .read(bookmarksProvider.notifier)
                              .toggle(scheme.id);
                        },
                        onToggleReminder: () async {
                          await ref
                              .read(remindersProvider.notifier)
                              .toggle(scheme.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


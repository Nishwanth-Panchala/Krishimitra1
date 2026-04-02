import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers/app_providers.dart';
import '../models/scheme.dart';
import '../services/url_service.dart';

class SchemeDetailsScreen extends ConsumerWidget {
  final String schemeId;

  const SchemeDetailsScreen({super.key, required this.schemeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemesAsync = ref.watch(schemesProvider);
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final remindersAsync = ref.watch(remindersProvider);

    final bookmarkedIds = bookmarksAsync.value ?? <String>{};
    final reminderIds = remindersAsync.value ?? <String>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheme Details'),
        actions: [
          IconButton(
            tooltip: 'Bookmark',
            onPressed: () async {
              final schemes = schemesAsync.valueOrNull;
              if (schemes == null) return;
              final matches = schemes.where((s) => s.id == schemeId).toList();
              if (matches.isEmpty) return;
              final scheme = matches.first;
              await ref
                  .read(bookmarksProvider.notifier)
                  .toggle(scheme.id);
            },
            icon: Icon(
              bookmarkedIds.contains(schemeId) ? Icons.bookmark : Icons.bookmark_border,
              color: bookmarkedIds.contains(schemeId) ? Colors.green : null,
            ),
          ),
          IconButton(
            tooltip: 'Reminder',
            onPressed: () async {
              final schemes = schemesAsync.valueOrNull;
              if (schemes == null) return;
              final matches = schemes.where((s) => s.id == schemeId).toList();
              if (matches.isEmpty) return;
              final scheme = matches.first;
              await ref.read(remindersProvider.notifier).toggle(scheme.id);
            },
            icon: Icon(
              reminderIds.contains(schemeId)
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: reminderIds.contains(schemeId) ? Colors.green : null,
            ),
          ),
        ],
      ),
      body: schemesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load: $err')),
        data: (schemes) {
          final matches =
              schemes.where((s) => s.id == schemeId).toList();
          final scheme = matches.isEmpty ? null : matches.first;
          if (scheme == null) {
            return const Center(child: Text('Scheme not found.'));
          }

          final isBookmarked = bookmarkedIds.contains(scheme.id);
          final isReminded = reminderIds.contains(scheme.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                scheme.schemeName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
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
                          : 'State',
                    ),
                  ),
                  if (scheme.schemeType == SchemeType.state &&
                      scheme.state.trim().isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.place, size: 18),
                      label: Text(scheme.state),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                scheme.basicInfo,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benefits',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      if (scheme.benefits.isEmpty)
                        const Text('No benefits data available.')
                      else
                        ...scheme.benefits.map(
                          (b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(child: Text(b)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Last date: ${scheme.lastDate.isEmpty ? 'N/A' : scheme.lastDate}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
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
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Apply'),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(bookmarksProvider.notifier)
                            .toggle(scheme.id);
                      },
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.green : null,
                      ),
                      label: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(remindersProvider.notifier).toggle(scheme.id);
                      },
                      icon: Icon(
                        isReminded ? Icons.notifications_active : Icons.notifications_none,
                        color: isReminded ? Colors.green : null,
                      ),
                      label: Text(isReminded ? 'Reminder set' : 'Set Reminder'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}


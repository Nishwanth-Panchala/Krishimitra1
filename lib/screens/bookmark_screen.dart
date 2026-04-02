import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers/app_providers.dart';
import '../services/url_service.dart';
import '../widgets/scheme_card.dart';

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemesAsync = ref.watch(schemesProvider);
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final remindersAsync = ref.watch(remindersProvider);

    final bookmarkedIds = bookmarksAsync.value ?? <String>{};
    final reminderIds = remindersAsync.value ?? <String>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Schemes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: schemesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load: $err')),
          data: (schemes) {
            final bookmarked = schemes
                .where((s) => bookmarkedIds.contains(s.id))
                .toList(growable: false);

            if (bookmarked.isEmpty) {
              return const Center(
                child: Text('No bookmarks yet. Tap the bookmark icon on a scheme.'),
              );
            }

            return ListView.separated(
              itemCount: bookmarked.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final scheme = bookmarked[index];
                return SchemeCard(
                  scheme: scheme,
                  isBookmarked: true,
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
    );
  }
}


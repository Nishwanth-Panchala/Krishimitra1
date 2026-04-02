import 'package:flutter/material.dart';

import '../models/scheme.dart';

class SchemeCard extends StatelessWidget {
  final Scheme scheme;
  final bool isBookmarked;
  final bool isReminded;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleReminder;
  final VoidCallback onApply;

  const SchemeCard({
    super.key,
    required this.scheme,
    required this.isBookmarked,
    required this.isReminded,
    required this.onTap,
    required this.onToggleBookmark,
    required this.onToggleReminder,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: isBookmarked ? 'Bookmarked' : 'Bookmark',
                    onPressed: onToggleBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.green : null,
                    ),
                  ),
                  IconButton(
                    tooltip: isReminded ? 'Reminder set' : 'Set reminder',
                    onPressed: onToggleReminder,
                    icon: Icon(
                      isReminded
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: isReminded ? Colors.green : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                scheme.basicInfo,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers/app_providers.dart';
import '../models/auth_role.dart';

class HomeShell extends ConsumerWidget {
  final Widget child;
  final String currentPath;

  const HomeShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(authRoleProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: roleAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (role) {
          final isAdmin = role == AuthRole.admin ||
              currentPath.startsWith('/admin/');

          if (isAdmin) {
            final selectedIndex = currentPath.startsWith('/admin/feedback')
                ? 1
                : currentPath.startsWith('/admin/notifications')
                    ? 2
                    : currentPath.startsWith('/admin/users')
                        ? 3
                        : 0;

            return BottomNavigationBar(
              currentIndex: selectedIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/admin/schemes');
                    break;
                  case 1:
                    context.go('/admin/feedback');
                    break;
                  case 2:
                    context.go('/admin/notifications');
                    break;
                  case 3:
                    context.go('/admin/users');
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.manage_accounts),
                  label: 'Manage Schemes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.feedback),
                  label: 'Feedback',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Users',
                ),
              ],
            );
          }

          final selectedIndex = currentPath.startsWith('/home/central')
              ? 1
              : currentPath.startsWith('/home/feedback')
                  ? 2
                  : currentPath.startsWith('/home/account')
                      ? 3
                      : 0;

          return BottomNavigationBar(
            currentIndex: selectedIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/home/state');
                  break;
                case 1:
                  context.go('/home/central');
                  break;
                case 2:
                  context.go('/home/feedback');
                  break;
                case 3:
                  context.go('/home/account');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.location_city),
                label: 'State Schemes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance),
                label: 'Central Schemes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.feedback),
                label: 'Feedback',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          );
        },
      ),
    );
  }
}


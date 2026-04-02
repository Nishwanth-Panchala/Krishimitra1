import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/schemes_local_data_source.dart';
import '../../data/schemes_repository.dart';
import '../../data/schemes_admin_store.dart';
import '../../models/scheme.dart';
import '../../models/auth_role.dart';
import '../../models/user_profile.dart';
import '../../models/feedback.dart';
import '../../services/bookmark_service.dart';
import '../../services/feedback_service.dart';
import '../../services/local_auth_service.dart';
import '../../services/local_user_storage.dart';
import '../../services/reminder_service.dart';
import '../../services/notification_service.dart';
import '../../models/app_notification.dart';

final schemesRepositoryProvider = Provider<SchemesRepository>(
  (ref) => SchemesRepository(
    SchemesLocalDataSource(),
    adminStore: SchemesAdminStore(),
  ),
);

final schemesProvider = FutureProvider<List<Scheme>>(
  (ref) => ref
      .watch(schemesRepositoryProvider)
      .fetchSchemesWithAdminOverrides(),
);

final localUserStorageProvider = Provider<LocalUserStorage>(
  (ref) => LocalUserStorage(),
);

final localAuthServiceProvider = Provider<LocalAuthService>(
  (ref) => LocalAuthService(ref.watch(localUserStorageProvider)),
);

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final storage = ref.watch(localUserStorageProvider);
  final authData = await storage.readUserAuth();
  return authData?.profile;
});

final registeredUserAuthProvider = FutureProvider<UserAuthData?>((ref) async {
  final storage = ref.watch(localUserStorageProvider);
  return storage.readUserAuth();
});

final authRoleProvider = FutureProvider<AuthRole?>((ref) async {
  final storage = ref.watch(localUserStorageProvider);
  return storage.readRole();
});

final bookmarkServiceProvider = Provider<BookmarkService>(
  (ref) => BookmarkService(),
);

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => ReminderService(),
);

class BookmarksController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final service = ref.read(bookmarkServiceProvider);
    return service.loadBookmarks();
  }

  Future<void> toggle(String schemeId) async {
    final current = state.value ?? <String>{};
    final next = {...current};

    if (next.contains(schemeId)) {
      next.remove(schemeId);
    } else {
      next.add(schemeId);
    }

    final service = ref.read(bookmarkServiceProvider);
    await service.saveBookmarks(next);
    state = AsyncValue.data(next);
  }
}

final bookmarksProvider =
    AsyncNotifierProvider<BookmarksController, Set<String>>(
  () => BookmarksController(),
);

class RemindersController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final service = ref.read(reminderServiceProvider);
    return service.loadReminderIds();
  }

  Future<void> toggle(String schemeId) async {
    final current = state.value ?? <String>{};
    final next = {...current};

    if (next.contains(schemeId)) {
      next.remove(schemeId);
    } else {
      next.add(schemeId);
    }

    final service = ref.read(reminderServiceProvider);
    await service.saveReminderIds(next);
    state = AsyncValue.data(next);
  }
}

final remindersProvider =
    AsyncNotifierProvider<RemindersController, Set<String>>(
  () => RemindersController(),
);

final feedbackServiceProvider = Provider<FeedbackService>(
  (ref) => FeedbackService(),
);

final feedbackProvider = FutureProvider<List<FeedbackEntry>>(
  (ref) => ref.read(feedbackServiceProvider).loadFeedback(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final notificationsProvider = FutureProvider<List<AppNotificationEntry>>(
  (ref) => ref.read(notificationServiceProvider).loadAll(),
);

final notificationReadIdsProvider = FutureProvider<Set<String>>(
  (ref) => ref.read(notificationServiceProvider).loadReadIds(),
);


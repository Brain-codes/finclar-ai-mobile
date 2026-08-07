import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config_notifier.dart' hide categoriesProvider;
import 'home_widget_service.dart';
import '../../features/home/providers/home_dashboard_provider.dart';
import '../../features/home/providers/income_setup_provider.dart';
import '../../features/expenses/providers/expense_providers.dart';
import '../../features/budget/providers/budget_providers.dart';
import '../../features/group/providers/friend_providers.dart';
import '../../features/group/providers/group_chat_hub_provider.dart';
import '../../features/group/providers/group_providers.dart';
import '../../features/clara/providers/clara_chat_provider.dart';
import '../../features/gamification/providers/challenge_providers.dart';
import '../../features/gamification/providers/streak_providers.dart';
import '../../features/gamification/providers/wrapped_providers.dart';
import '../../features/onboarding/providers/tour_provider.dart';

/// Every cached, user-scoped data provider. Invalidating these drops the
/// previous user's dashboard/financial data so it never leaks into the next
/// session. Deliberately excludes saved credentials/auth state — that lives in
/// `authStateService` / secure storage so the user can still log back in.
///
/// `groupChatHubProvider`/`groupChatNotificationsProvider` MUST be invalidated
/// on logout — otherwise the previous user's group chat sockets (and the
/// notification banners they'd trigger) would keep running into the next
/// session. Invalidating `groupChatHubProvider` disposes every open socket
/// (see its `ref.onDispose`); invalidating `groupChatNotificationsProvider`
/// tears down its listeners so it re-subscribes fresh for the next user (via
/// `AppShell`'s `ref.watch` on next login).
final _userScopedProviders = <ProviderOrFamily>[
  homeSummaryProvider,
  homeInsightProvider,
  incomeProvider,
  incomeSourcesProvider,
  expenseListProvider,
  categoriesProvider,
  budgetProvider,
  friendsProvider,
  friendInvitesProvider,
  groupsProvider,
  groupChatNotificationsProvider,
  groupChatHubProvider,
  activeGroupChatIdProvider,
  claraChatProvider,
  wrappedProvider,
  challengesProvider,
  challengeEntriesProvider,
  myBadgesProvider,
  expenseStreakProvider,
  // Re-reads the (now cleared) tour flag for the next session.
  tourProvider,
];

/// Clears user-scoped data from a widget (e.g. the logout sheet).
void clearUserScopedData(WidgetRef ref) {
  for (final provider in _userScopedProviders) {
    ref.invalidate(provider);
  }
  ref.read(appConfigProvider.notifier).reset();
  HomeWidgetService.clear();
}

/// Clears user-scoped data from a provider/notifier (e.g. on login success),
/// guaranteeing the next user always fetches fresh data.
void clearUserScopedDataRef(Ref ref) {
  for (final provider in _userScopedProviders) {
    ref.invalidate(provider);
  }
  ref.read(appConfigProvider.notifier).reset();
  HomeWidgetService.clear();
}

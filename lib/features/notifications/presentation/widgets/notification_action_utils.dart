import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/notification_model.dart';

class NotificationAction {
  final String label;
  final String route;

  const NotificationAction(this.label, this.route);
}

/// Where a notification row can send the user. Returns null for types with
/// nothing actionable behind them — those rows show no CTA rather than a
/// button that goes nowhere.
///
/// Group types deliberately land on the group list, not `groupDetail`: that
/// route takes a `GroupModel` via `extra` and a notification only carries a
/// `group_id`, so there is nothing to hand it.
NotificationAction? notificationActionFor(NotificationType type) {
  switch (type) {
    case NotificationType.friendInvite:
      return const NotificationAction(
        AppStrings.notificationViewRequest,
        RouteNames.friends,
      );
    case NotificationType.groupInvite:
    case NotificationType.groupActivity:
      return const NotificationAction(
        AppStrings.notificationViewGroup,
        RouteNames.group,
      );
    case NotificationType.budgetNearLimit:
      return const NotificationAction(
        AppStrings.notificationViewBudget,
        RouteNames.budget,
      );
    case NotificationType.bankSyncCompleted:
      return const NotificationAction(
        AppStrings.notificationViewTransactions,
        RouteNames.expenses,
      );
    case NotificationType.subscriptionActivated:
      return const NotificationAction(
        AppStrings.notificationViewPlan,
        RouteNames.subscription,
      );
    case NotificationType.unknown:
      return null;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/routes/app_router.dart';
import '../../features/gamification/data/models/challenge_model.dart';
import '../../features/gamification/presentation/widgets/challenge_prompts.dart';
import 'logger_service.dart';
import 'notification_service.dart';

/// Routes a tapped push to the screen it's about. Registered once at startup;
/// before this, [NotificationService] fired taps into a handler nobody set.
void registerNotificationRouting() {
  NotificationService.setTapHandler((category, data) {
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context == null) {
      Log.w('Notification tapped before the app had a navigator');
      return;
    }

    switch (category) {
      case NotificationCategory.challenge:
        final container = ProviderScope.containerOf(context);
        // Unknown or generic challenge payloads fall back to Friday savings —
        // that's the reminder the backend sends on a schedule today.
        final type = ChallengeType.fromString(
          (data['challenge_type'] ?? data['type']) as String?,
        );
        switch (type) {
          case ChallengeType.fridaySavings:
            maybeShowFridayChallengePrompt(
              context,
              container,
              fromPush: true,
              challengeId: data['challenge_id'] as String?,
            );
          case ChallengeType.noSpend:
            maybeShowWeekendChallengePrompt(context, container, fromPush: true);
          case ChallengeType.budgetCategory:
            maybeShowCategoryChallengePrompt(
              context,
              container,
              fromPush: true,
            );
        }
      case NotificationCategory.transaction:
      case NotificationCategory.budget:
      case NotificationCategory.group:
      case NotificationCategory.aiInsight:
      case NotificationCategory.unknown:
        Log.i('No route wired for notification category $category');
    }
  });
}

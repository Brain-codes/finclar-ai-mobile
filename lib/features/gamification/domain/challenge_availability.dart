import 'dart:math';

import '../data/models/challenge_model.dart';

/// When each challenge type can be started, and how that reads to the user.
///
/// Challenges are meant to arrive rather than sit in a menu — the no-spend one
/// only exists over a weekend, and the category one turns up unannounced. This
/// is the single source of truth for both the cards on the challenges screen
/// and the prompts that surface on app open.
class ChallengeAvailability {
  final ChallengeType type;

  /// False when the type has a window and today is outside it.
  final bool isOpen;
  final String windowLabel;

  /// Sent as the challenge's `end_date` so the backend closes it when the
  /// window does. Null for types that run open-ended.
  final DateTime? closesAt;

  const ChallengeAvailability({
    required this.type,
    required this.isOpen,
    required this.windowLabel,
    this.closesAt,
  });
}

/// The no-spend weekend runs Friday 00:00 to Sunday 23:59 local — the modal
/// promises "Friday to Sunday", so the window has to match the copy.
bool isWeekendOpen(DateTime now) => now.weekday >= DateTime.friday;

/// End of the weekend that contains, or next follows, [now].
DateTime weekendEnd(DateTime now) {
  final sunday = now.add(Duration(days: DateTime.sunday - now.weekday));
  return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
}

/// Friday of the coming weekend, so a closed card can say when it returns.
DateTime nextWeekendStart(DateTime now) {
  final delta = (DateTime.friday - now.weekday + 7) % 7;
  final friday = now.add(Duration(days: delta));
  return DateTime(friday.year, friday.month, friday.day);
}

ChallengeAvailability challengeAvailability(ChallengeType type, DateTime now) {
  switch (type) {
    case ChallengeType.fridaySavings:
      return ChallengeAvailability(
        type: type,
        isOpen: true,
        windowLabel: 'Every Friday',
      );
    case ChallengeType.noSpend:
      final open = isWeekendOpen(now);
      return ChallengeAvailability(
        type: type,
        isOpen: open,
        windowLabel: open ? 'This weekend only' : 'Opens Friday',
        closesAt: open ? weekendEnd(now) : null,
      );
    case ChallengeType.budgetCategory:
      return ChallengeAvailability(
        type: type,
        isOpen: true,
        windowLabel: 'Anytime',
      );
  }
}

/// Every type that isn't already running, in the order they should be offered.
List<ChallengeAvailability> availableChallenges({
  required DateTime now,
  required Set<ChallengeType> running,
}) => [
  for (final type in ChallengeType.values)
    if (!running.contains(type)) challengeAvailability(type, now),
];

/// The category-budget nudge lands on an unpredictable day rather than a fixed
/// one — a prompt you can time is a prompt you learn to ignore. 5 to 12 days
/// out, so it averages a little over a week.
DateTime nextCategoryPromptDate(DateTime now, [Random? random]) {
  final days = 5 + (random ?? Random()).nextInt(8);
  return DateTime(now.year, now.month, now.day).add(Duration(days: days));
}

/// `yyyy-MM-dd`, the format the scheduled prompt dates are persisted in.
String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

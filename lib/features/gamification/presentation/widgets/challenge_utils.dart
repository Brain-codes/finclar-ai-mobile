import '../../data/models/challenge_model.dart';

/// ISO-8601 week label, e.g. `2026-W31` — the same format the backend returns
/// in `last_entry_week`, so the two can be compared directly.
String isoWeekLabel(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  final thursday = day.add(Duration(days: 4 - day.weekday));
  final week =
      thursday.difference(DateTime.utc(thursday.year, 1, 1)).inDays ~/ 7 + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

bool hasSavedThisWeek(ChallengeModel challenge) =>
    challenge.lastEntryWeek != null &&
    challenge.lastEntryWeek == isoWeekLabel(DateTime.now());

String challengeTypeLabel(ChallengeType type) => switch (type) {
  ChallengeType.fridaySavings => 'Friday Savings',
  ChallengeType.noSpend => 'No spend challenge',
  ChallengeType.budgetCategory => 'Category budget',
};

String challengeTypeBlurb(ChallengeType type) => switch (type) {
  ChallengeType.fridaySavings =>
    'Save your target every Friday before midnight and keep the streak alive. '
        'Miss a Friday and the streak resets.',
  ChallengeType.noSpend =>
    'Set the most you can spend and go as low as you can. Expenses you log '
        'count towards it automatically.',
  ChallengeType.budgetCategory =>
    'Pick a category and a cap. Every expense you log in that category counts '
        'against it — stay under to keep the streak.',
};

String challengeStatusLabel(ChallengeModel challenge) =>
    switch (challenge.status) {
      ChallengeStatus.completed => 'Completed',
      ChallengeStatus.cancelled => 'Cancelled',
      ChallengeStatus.failed => switch (challenge.type) {
        ChallengeType.noSpend => 'Streak broken — you spent',
        ChallengeType.budgetCategory => 'Went over the cap',
        ChallengeType.fridaySavings => 'Streak broken',
      },
      ChallengeStatus.active => switch (challenge.type) {
        ChallengeType.noSpend => 'No spending yet — keep it up',
        ChallengeType.budgetCategory => 'Under the cap so far',
        ChallengeType.fridaySavings =>
          hasSavedThisWeek(challenge) ? 'Saved this week' : 'Due this Friday',
      },
    };

/// What the big number on a card/summary is measuring. Spend-based types are
/// judged on what they've spent, savings types on what they've put away.
String challengeAmountLabel(ChallengeModel challenge) =>
    challenge.type.isSpendBased ? 'Spent this period' : 'Total saved';

/// The figure [challengeAmountLabel] describes.
double challengeAmount(ChallengeModel challenge) => challenge.type.isSpendBased
    ? (challenge.currentPeriodSpent ?? 0)
    : challenge.totalSaved;

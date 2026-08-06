import 'dart:math';

import 'package:finclar_ai/features/gamification/data/models/challenge_model.dart';
import 'package:finclar_ai/features/gamification/domain/challenge_availability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 2026-08-03 is a Monday, so the weekday arithmetic below is readable.
  DateTime monday(int hour) => DateTime(2026, 8, 3, hour);
  DateTime day(int dayOfMonth, [int hour = 12]) =>
      DateTime(2026, 8, dayOfMonth, hour);

  group('weekend window', () {
    test('opens on Friday and stays open through Sunday', () {
      expect(isWeekendOpen(day(7)), isTrue); // Friday
      expect(isWeekendOpen(day(8)), isTrue); // Saturday
      expect(isWeekendOpen(day(9)), isTrue); // Sunday
    });

    test('is closed Monday to Thursday', () {
      for (final d in [3, 4, 5, 6]) {
        expect(isWeekendOpen(day(d)), isFalse, reason: 'Aug $d');
      }
    });

    test('ends at the last second of Sunday', () {
      expect(weekendEnd(day(7)), DateTime(2026, 8, 9, 23, 59, 59));
      expect(weekendEnd(day(9, 23)), DateTime(2026, 8, 9, 23, 59, 59));
    });

    test('next start is the coming Friday, or today when it is Friday', () {
      expect(nextWeekendStart(monday(9)), DateTime(2026, 8, 7));
      expect(nextWeekendStart(day(7, 9)), DateTime(2026, 8, 7));
    });
  });

  group('challengeAvailability', () {
    test('no spend carries the weekend end as its close date', () {
      final friday = challengeAvailability(ChallengeType.noSpend, day(7));
      expect(friday.isOpen, isTrue);
      expect(friday.closesAt, DateTime(2026, 8, 9, 23, 59, 59));

      final tuesday = challengeAvailability(ChallengeType.noSpend, day(4));
      expect(tuesday.isOpen, isFalse);
      expect(tuesday.closesAt, isNull);
      expect(tuesday.windowLabel, 'Opens Friday');
    });

    test('the other two types are always open and never expire', () {
      for (final type in [
        ChallengeType.fridaySavings,
        ChallengeType.budgetCategory,
      ]) {
        final a = challengeAvailability(type, day(4));
        expect(a.isOpen, isTrue);
        expect(a.closesAt, isNull);
      }
    });
  });

  group('availableChallenges', () {
    test('drops types that are already running', () {
      final result = availableChallenges(
        now: day(7),
        running: {ChallengeType.fridaySavings},
      );
      expect(result.map((a) => a.type), [
        ChallengeType.noSpend,
        ChallengeType.budgetCategory,
      ]);
    });

    test('keeps closed types listed so the cadence stays visible', () {
      final result = availableChallenges(now: day(4), running: const {});
      expect(result.length, 3);
      expect(
        result.firstWhere((a) => a.type == ChallengeType.noSpend).isOpen,
        isFalse,
      );
    });
  });

  group('nextCategoryPromptDate', () {
    test('lands 5 to 12 days out, on a date boundary', () {
      for (var seed = 0; seed < 50; seed++) {
        final next = nextCategoryPromptDate(monday(15), Random(seed));
        final gap = next.difference(DateTime(2026, 8, 3)).inDays;
        expect(gap, greaterThanOrEqualTo(5));
        expect(gap, lessThanOrEqualTo(12));
        expect(next.hour, 0);
      }
    });

    test('does not always pick the same day', () {
      final dates = {
        for (var seed = 0; seed < 20; seed++)
          nextCategoryPromptDate(monday(15), Random(seed)),
      };
      expect(dates.length, greaterThan(1));
    });
  });

  test('dateKey round-trips through DateTime.parse', () {
    final key = dateKey(DateTime(2026, 8, 9));
    expect(key, '2026-08-09');
    expect(DateTime.parse(key), DateTime(2026, 8, 9));
  });
}

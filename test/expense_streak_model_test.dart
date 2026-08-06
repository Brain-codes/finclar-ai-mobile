import 'package:flutter_test/flutter_test.dart';
import 'package:finclar_ai/features/gamification/data/models/expense_streak_model.dart';

Map<String, dynamic> _day(String label, bool logged, {bool isToday = false}) => {
  'date': '2026-08-0${label.length}',
  'day_label': label,
  'logged': logged,
  'is_today': isToday,
};

void main() {
  group('ExpenseStreakModel', () {
    test('parses the full payload', () {
      final model = ExpenseStreakModel.fromJson({
        'current_streak': 5,
        'longest_streak': 12,
        'last_logged_date': '2026-08-05',
        'logged_today': true,
        'days': [
          _day('Sa', true),
          _day('Su', true),
          _day('Mo', true, isToday: true),
          _day('Tu', false),
        ],
      });

      expect(model.currentStreak, 5);
      expect(model.longestStreak, 12);
      expect(model.lastLoggedDate, DateTime.parse('2026-08-05'));
      expect(model.loggedToday, isTrue);
      expect(model.days, hasLength(4));
      expect(model.days.first.dayLabel, 'Sa');
      expect(model.today?.dayLabel, 'Mo');
    });

    test('defaults days to an empty list rather than null', () {
      final model = ExpenseStreakModel.fromJson({
        'current_streak': 0,
        'longest_streak': 0,
        'last_logged_date': null,
        'logged_today': false,
      });

      expect(model.days, isEmpty);
      expect(model.lastLoggedDate, isNull);
      expect(model.hasStreak, isFalse);
      expect(model.today, isNull);
    });

    test('coerces string counts the backend may serialise as text', () {
      final model = ExpenseStreakModel.fromJson({
        'current_streak': '7',
        'longest_streak': '9',
        'logged_today': true,
        'days': [],
      });

      expect(model.currentStreak, 7);
      expect(model.longestStreak, 9);
    });

    test('isPersonalBest only once the run matches the record', () {
      ExpenseStreakModel build(int current, int longest) => ExpenseStreakModel(
        currentStreak: current,
        longestStreak: longest,
        loggedToday: true,
        days: const [],
      );

      expect(build(4, 12).isPersonalBest, isFalse);
      expect(build(12, 12).isPersonalBest, isTrue);
      expect(build(0, 0).isPersonalBest, isFalse);
    });

    test('round-trips through toJson', () {
      const model = ExpenseStreakModel(
        currentStreak: 3,
        longestStreak: 8,
        loggedToday: true,
        days: [
          ExpenseStreakDayModel(dayLabel: 'Mo', logged: true, isToday: true),
        ],
      );

      final json = model.toJson();
      expect(json['current_streak'], 3);
      expect(json['logged_today'], true);
      expect(json['last_logged_date'], isNull);
      expect((json['days'] as List).single, {
        'date': null,
        'day_label': 'Mo',
        'logged': true,
        'is_today': true,
      });
    });
  });
}

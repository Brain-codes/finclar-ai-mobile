import 'package:flutter_test/flutter_test.dart';
import 'package:finclar_ai/features/gamification/data/models/challenge_model.dart';

void main() {
  group('ChallengeType', () {
    test('parses every live backend value', () {
      expect(
        ChallengeType.fromString('friday_savings'),
        ChallengeType.fridaySavings,
      );
      expect(ChallengeType.fromString('no_spend'), ChallengeType.noSpend);
      expect(
        ChallengeType.fromString('budget_category'),
        ChallengeType.budgetCategory,
      );
    });

    test('falls back to friday savings on an unknown or null type', () {
      expect(ChallengeType.fromString('time_travel'), ChallengeType.fridaySavings);
      expect(ChallengeType.fromString(null), ChallengeType.fridaySavings);
    });

    test('only friday savings is not spend-based', () {
      expect(ChallengeType.fridaySavings.isSpendBased, isFalse);
      expect(ChallengeType.noSpend.isSpendBased, isTrue);
      expect(ChallengeType.budgetCategory.isSpendBased, isTrue);
    });
  });

  group('ChallengeStatus', () {
    test('parses failed rather than treating it as active', () {
      expect(ChallengeStatus.fromString('failed'), ChallengeStatus.failed);
      expect(ChallengeStatus.fromString('completed'), ChallengeStatus.completed);
      expect(ChallengeStatus.fromString('cancelled'), ChallengeStatus.cancelled);
      expect(ChallengeStatus.fromString('active'), ChallengeStatus.active);
    });
  });

  group('ChallengeModel', () {
    test('parses a budget_category challenge with its spend fields', () {
      final model = ChallengeModel.fromJson({
        'id': 'c1',
        'user_id': 'u1',
        'type': 'budget_category',
        'name': 'Eating out cap',
        'weekly_target': null,
        'overall_target': '20000.00',
        'total_saved': '0.00',
        'current_streak': 2,
        'longest_streak': 3,
        'last_entry_week': null,
        'target_category_id': 'cat-9',
        'current_period_spent': '7500.50',
        'start_date': '2026-08-01',
        'end_date': null,
        'status': 'active',
        'created_at': '2026-08-01T00:00:00Z',
        'progress_percent': 37.5,
      });

      expect(model.type, ChallengeType.budgetCategory);
      expect(model.targetCategoryId, 'cat-9');
      expect(model.currentPeriodSpent, 7500.50);
      expect(model.overallTarget, 20000.00);
      expect(model.isActive, isTrue);
    });

    test('round-trips type and the spend fields through toJson', () {
      const model = ChallengeModel(
        id: 'c1',
        userId: 'u1',
        type: ChallengeType.noSpend,
        name: 'No spend weekend',
        totalSaved: 0,
        currentStreak: 0,
        longestStreak: 0,
        targetCategoryId: 'cat-9',
        currentPeriodSpent: 0,
        status: ChallengeStatus.failed,
      );

      final json = model.toJson();
      expect(json['type'], 'no_spend');
      expect(json['status'], 'failed');
      expect(json['target_category_id'], 'cat-9');
      expect(json['current_period_spent'], 0);
    });

    test('leaves the spend fields null for a friday savings challenge', () {
      final model = ChallengeModel.fromJson({
        'id': 'c2',
        'user_id': 'u1',
        'type': 'friday_savings',
        'name': 'Friday Savings Challenge',
        'weekly_target': '5000.00',
        'total_saved': '45000.00',
        'current_streak': 9,
        'longest_streak': 9,
        'status': 'active',
      });

      expect(model.type, ChallengeType.fridaySavings);
      expect(model.targetCategoryId, isNull);
      expect(model.currentPeriodSpent, isNull);
      expect(model.totalSaved, 45000.00);
    });
  });
}

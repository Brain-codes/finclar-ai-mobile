import 'dart:convert';

ChallengeModel challengeModelFromJson(String str) =>
    ChallengeModel.fromJson(json.decode(str));

String challengeModelToJson(ChallengeModel data) => json.encode(data.toJson());

/// Unknown values map to [fridaySavings] rather than throwing — a new
/// server-side type must not crash the list.
enum ChallengeType {
  fridaySavings('friday_savings'),
  noSpend('no_spend'),
  budgetCategory('budget_category');

  const ChallengeType(this.value);

  final String value;

  static ChallengeType fromString(String? value) => switch (value) {
    'no_spend' => ChallengeType.noSpend,
    'budget_category' => ChallengeType.budgetCategory,
    _ => ChallengeType.fridaySavings,
  };

  /// [noSpend] and [budgetCategory] are measured by what you *didn't* spend, so
  /// they report `current_period_spent` against a cap instead of accumulating
  /// `total_saved`.
  bool get isSpendBased => this != ChallengeType.fridaySavings;
}

enum ChallengeStatus {
  active,
  completed,
  cancelled,
  failed;

  static ChallengeStatus fromString(String? value) => switch (value) {
    'completed' => ChallengeStatus.completed,
    'cancelled' => ChallengeStatus.cancelled,
    'failed' => ChallengeStatus.failed,
    _ => ChallengeStatus.active,
  };

  String get value => name;
}

/// Deliberately separate from `ExpenseVerificationLevel` — the backend keeps
/// the two isolated, and the values differ (`evidence_backed`, not `verified`).
enum EntryVerificationLevel {
  selfReported,
  evidenceBacked;

  static EntryVerificationLevel fromString(String? value) =>
      value == 'evidence_backed'
      ? EntryVerificationLevel.evidenceBacked
      : EntryVerificationLevel.selfReported;

  String get value => this == EntryVerificationLevel.evidenceBacked
      ? 'evidence_backed'
      : 'self_reported';
}

class ChallengeModel {
  final String id;
  final String userId;
  final ChallengeType type;
  final String name;
  final double? weeklyTarget;
  final double? overallTarget;
  final double totalSaved;
  final int currentStreak;
  final int longestStreak;

  /// ISO week the last entry landed in, e.g. `2026-W31`. Null before the first
  /// entry — use it to tell "already saved this week" from "not yet".
  final String? lastEntryWeek;

  /// The category being capped. Only set on [ChallengeType.budgetCategory].
  final String? targetCategoryId;

  /// Spent so far this period. Only set on spend-based types — this is what
  /// they're judged on, not [totalSaved].
  final double? currentPeriodSpent;
  final DateTime? startDate;
  final DateTime? endDate;
  final ChallengeStatus status;
  final DateTime? createdAt;

  /// Backend-computed against [overallTarget]; null when no overall target set.
  final double? progressPercent;

  const ChallengeModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.weeklyTarget,
    this.overallTarget,
    required this.totalSaved,
    required this.currentStreak,
    required this.longestStreak,
    this.lastEntryWeek,
    this.targetCategoryId,
    this.currentPeriodSpent,
    this.startDate,
    this.endDate,
    required this.status,
    this.createdAt,
    this.progressPercent,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => ChallengeModel(
    id: json['id'] as String? ?? '',
    userId: json['user_id'] as String? ?? '',
    type: ChallengeType.fromString(json['type'] as String?),
    name: json['name'] as String? ?? '',
    weeklyTarget: _toDoubleOrNull(json['weekly_target']),
    overallTarget: _toDoubleOrNull(json['overall_target']),
    totalSaved: _toDoubleOrNull(json['total_saved']) ?? 0,
    currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
    longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
    lastEntryWeek: json['last_entry_week'] as String?,
    targetCategoryId: json['target_category_id'] as String?,
    currentPeriodSpent: _toDoubleOrNull(json['current_period_spent']),
    startDate: _toDate(json['start_date']),
    endDate: _toDate(json['end_date']),
    status: ChallengeStatus.fromString(json['status'] as String?),
    createdAt: _toDate(json['created_at']),
    progressPercent: _toDoubleOrNull(json['progress_percent']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type.value,
    'name': name,
    'weekly_target': weeklyTarget,
    'overall_target': overallTarget,
    'total_saved': totalSaved,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'last_entry_week': lastEntryWeek,
    'target_category_id': targetCategoryId,
    'current_period_spent': currentPeriodSpent,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'status': status.value,
    'created_at': createdAt?.toIso8601String(),
    'progress_percent': progressPercent,
  };

  bool get isActive => status == ChallengeStatus.active;
}

class ChallengeEntryModel {
  final String id;
  final double? amount;
  final EntryVerificationLevel verificationLevel;
  final String? note;
  final String? fileUrl;
  final DateTime? recordedAt;

  const ChallengeEntryModel({
    required this.id,
    this.amount,
    required this.verificationLevel,
    this.note,
    this.fileUrl,
    this.recordedAt,
  });

  factory ChallengeEntryModel.fromJson(Map<String, dynamic> json) =>
      ChallengeEntryModel(
        id: json['id'] as String? ?? '',
        amount: _toDoubleOrNull(json['amount']),
        verificationLevel: EntryVerificationLevel.fromString(
          json['verification_level'] as String?,
        ),
        note: json['note'] as String?,
        fileUrl: json['file_url'] as String?,
        recordedAt: _toDate(json['recorded_at']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'verification_level': verificationLevel.value,
    'note': note,
    'file_url': fileUrl,
    'recorded_at': recordedAt?.toIso8601String(),
  };
}

class BadgeModel {
  final String key;
  final String name;
  final String description;
  final String? iconName;
  final String? category;

  const BadgeModel({
    required this.key,
    required this.name,
    required this.description,
    this.iconName,
    this.category,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
    key: json['key'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    iconName: json['icon_name'] as String?,
    category: json['category'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'description': description,
    'icon_name': iconName,
    'category': category,
  };
}

class UserBadgeModel {
  final BadgeModel badge;

  /// The period it was earned for, e.g. `2026-W31`.
  final String? earnedPeriod;
  final DateTime? earnedAt;

  const UserBadgeModel({required this.badge, this.earnedPeriod, this.earnedAt});

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) => UserBadgeModel(
    badge: BadgeModel.fromJson(
      (json['badge'] as Map<String, dynamic>?) ?? const {},
    ),
    earnedPeriod: json['earned_period'] as String?,
    earnedAt: _toDate(json['earned_at']),
  );

  Map<String, dynamic> toJson() => {
    'badge': badge.toJson(),
    'earned_period': earnedPeriod,
    'earned_at': earnedAt?.toIso8601String(),
  };
}

/// Money arrives as a string on these DTOs (e.g. `"5000.00"`), unlike the
/// number-typed summary endpoints.
double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _toDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

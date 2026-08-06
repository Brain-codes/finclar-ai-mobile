import 'dart:convert';

ExpenseStreakModel expenseStreakModelFromJson(String str) =>
    ExpenseStreakModel.fromJson(json.decode(str));

String expenseStreakModelToJson(ExpenseStreakModel data) =>
    json.encode(data.toJson());

/// Consecutive days the user has logged an expense. Distinct from
/// `ChallengeModel.currentStreak`, which counts *weeks* of a Friday Savings
/// challenge — this one is driven purely by expense logging and exists whether
/// or not any challenge is running.
class ExpenseStreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastLoggedDate;
  final bool loggedToday;

  /// The rolling window the backend wants rendered — already ordered and
  /// labelled, so the UI never derives day names itself.
  final List<ExpenseStreakDayModel> days;

  const ExpenseStreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastLoggedDate,
    required this.loggedToday,
    required this.days,
  });

  factory ExpenseStreakModel.fromJson(Map<String, dynamic> json) =>
      ExpenseStreakModel(
        currentStreak: _toInt(json['current_streak']),
        longestStreak: _toInt(json['longest_streak']),
        lastLoggedDate: _toDate(json['last_logged_date']),
        loggedToday: json['logged_today'] == true,
        days: json['days'] != null
            ? List<ExpenseStreakDayModel>.from(
                json['days'].map(
                  (x) =>
                      ExpenseStreakDayModel.fromJson(x as Map<String, dynamic>),
                ),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'last_logged_date': lastLoggedDate?.toIso8601String(),
    'logged_today': loggedToday,
    'days': List<dynamic>.from(days.map((x) => x.toJson())),
  };

  bool get hasStreak => currentStreak > 0;

  /// True when the current run has reached the best the user has ever managed.
  bool get isPersonalBest =>
      currentStreak > 0 && currentStreak >= longestStreak;

  ExpenseStreakDayModel? get today => days.where((d) => d.isToday).firstOrNull;
}

class ExpenseStreakDayModel {
  final DateTime? date;

  /// Backend-supplied short label (e.g. `Mo`). Rendered verbatim so the app and
  /// the server never disagree about where the week starts.
  final String dayLabel;
  final bool logged;
  final bool isToday;

  const ExpenseStreakDayModel({
    this.date,
    required this.dayLabel,
    required this.logged,
    required this.isToday,
  });

  factory ExpenseStreakDayModel.fromJson(Map<String, dynamic> json) =>
      ExpenseStreakDayModel(
        date: _toDate(json['date']),
        dayLabel: json['day_label'] as String? ?? '',
        logged: json['logged'] == true,
        isToday: json['is_today'] == true,
      );

  Map<String, dynamic> toJson() => {
    'date': date?.toIso8601String(),
    'day_label': dayLabel,
    'logged': logged,
    'is_today': isToday,
  };
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _toDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

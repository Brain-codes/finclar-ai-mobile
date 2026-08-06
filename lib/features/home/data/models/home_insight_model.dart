import 'dart:convert';

HomeInsightModel homeInsightModelFromJson(String str) =>
    HomeInsightModel.fromJson(json.decode(str));

String homeInsightModelToJson(HomeInsightModel data) =>
    json.encode(data.toJson());

/// `GET /insights/home` — the Clara sentence plus the figures it was derived
/// from. Money values are numbers; the two percentages are 0–100.
class HomeInsightModel {
  final String insight;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalIncome;
  final double totalExpenses;
  final double availableBalance;
  final double verifiedPct;
  final double selfReportedPct;

  const HomeInsightModel({
    required this.insight,
    this.startDate,
    this.endDate,
    required this.totalIncome,
    required this.totalExpenses,
    required this.availableBalance,
    required this.verifiedPct,
    required this.selfReportedPct,
  });

  factory HomeInsightModel.fromJson(Map<String, dynamic> json) =>
      HomeInsightModel(
        insight: json['insight'] as String? ?? '',
        startDate: json['start_date'] != null
            ? DateTime.tryParse(json['start_date'].toString())
            : null,
        endDate: json['end_date'] != null
            ? DateTime.tryParse(json['end_date'].toString())
            : null,
        totalIncome: _toDouble(json['total_income']),
        totalExpenses: _toDouble(json['total_expenses']),
        availableBalance: _toDouble(json['available_balance']),
        verifiedPct: _toDouble(json['verified_pct']),
        selfReportedPct: _toDouble(json['self_reported_pct']),
      );

  Map<String, dynamic> toJson() => {
        'insight': insight,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'total_income': totalIncome,
        'total_expenses': totalExpenses,
        'available_balance': availableBalance,
        'verified_pct': verifiedPct,
        'self_reported_pct': selfReportedPct,
      };

  bool get hasInsight => insight.trim().isNotEmpty;

  /// True once there is any expense data to attribute — both percentages sit at
  /// 0 for a period with no expenses, where a verified/self-reported split
  /// would be meaningless.
  bool get hasVerificationData => verifiedPct > 0 || selfReportedPct > 0;

  /// Whole-number percentages for display. Rounding each independently can make
  /// the pair read as 99% or 101%, so the self-reported half is derived from
  /// the rounded verified half.
  int get verifiedPctRounded => verifiedPct.round().clamp(0, 100);

  int get selfReportedPctRounded => 100 - verifiedPctRounded;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

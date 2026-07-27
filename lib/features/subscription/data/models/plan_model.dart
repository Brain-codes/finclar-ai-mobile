import 'dart:convert';

PlansResponseModel plansResponseFromJson(String str) =>
    PlansResponseModel.fromJson(json.decode(str));

enum PlanCode {
  monthly('go_unlimited_monthly'),
  yearly('go_unlimited_yearly');

  final String value;
  const PlanCode(this.value);

  static PlanCode? fromValue(String? value) {
    for (final code in PlanCode.values) {
      if (code.value == value) return code;
    }
    return null;
  }
}

class PlansResponseModel {
  final String paystackPublicKey;
  final List<PlanModel> plans;

  PlansResponseModel({
    required this.paystackPublicKey,
    required this.plans,
  });

  factory PlansResponseModel.fromJson(Map<String, dynamic> json) =>
      PlansResponseModel(
        paystackPublicKey: json["paystack_public_key"] ?? '',
        plans: json["plans"] != null
            ? List<PlanModel>.from(
                json["plans"].map((x) => PlanModel.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "paystack_public_key": paystackPublicKey,
        "plans": List<dynamic>.from(plans.map((x) => x.toJson())),
      };

  PlanModel? byCode(PlanCode code) {
    for (final plan in plans) {
      if (plan.code == code) return plan;
    }
    return null;
  }
}

class PlanModel {
  final PlanCode? code;
  final String name;

  /// Minor units (kobo for NGN) — Paystack's convention. Use [majorAmount]
  /// for anything shown to the user.
  final int amount;
  final int? compareAtAmount;
  final String currency;
  final int intervalDays;
  final int trialDays;
  final List<String> features;

  PlanModel({
    this.code,
    required this.name,
    required this.amount,
    this.compareAtAmount,
    required this.currency,
    required this.intervalDays,
    required this.trialDays,
    required this.features,
  });

  double get majorAmount => amount / 100;

  double? get compareAtMajorAmount =>
      compareAtAmount != null ? compareAtAmount! / 100 : null;

  bool get isYearly => intervalDays >= 365;

  int? get savingsPercent {
    final compare = compareAtAmount;
    if (compare == null || compare <= 0 || compare <= amount) return null;
    return (((compare - amount) / compare) * 100).round();
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        code: PlanCode.fromValue(json["code"]),
        name: json["name"] ?? '',
        amount: json["amount"] ?? 0,
        compareAtAmount: json["compare_at_amount"],
        currency: json["currency"] ?? '',
        intervalDays: json["interval_days"] ?? 0,
        trialDays: json["trial_days"] ?? 0,
        features: json["features"] != null
            ? List<String>.from(json["features"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "code": code?.value,
        "name": name,
        "amount": amount,
        "compare_at_amount": compareAtAmount,
        "currency": currency,
        "interval_days": intervalDays,
        "trial_days": trialDays,
        "features": List<dynamic>.from(features.map((x) => x)),
      };
}

import 'dart:convert';

import 'plan_model.dart';

SubscriptionModel subscriptionModelFromJson(String str) =>
    SubscriptionModel.fromJson(json.decode(str));

class SubscriptionModel {
  final PlanCode? planCode;
  final String status;
  final int? amount;
  final String? currency;
  final DateTime? trialEnd;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? canceledAt;

  SubscriptionModel({
    this.planCode,
    required this.status,
    this.amount,
    this.currency,
    this.trialEnd,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    this.canceledAt,
  });

  double? get majorAmount => amount != null ? amount! / 100 : null;

  bool get isActive => status == 'active' || status == 'trialing';

  bool get isTrialing => status == 'trialing';

  /// Active but already scheduled to end — the resume path applies here.
  bool get isEndingAtPeriodEnd => isActive && cancelAtPeriodEnd;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        planCode: PlanCode.fromValue(json["plan_code"]),
        status: json["status"] ?? 'none',
        amount: json["amount"],
        currency: json["currency"],
        trialEnd: _parseDate(json["trial_end"]),
        currentPeriodStart: _parseDate(json["current_period_start"]),
        currentPeriodEnd: _parseDate(json["current_period_end"]),
        cancelAtPeriodEnd: json["cancel_at_period_end"] ?? false,
        canceledAt: _parseDate(json["canceled_at"]),
      );

  Map<String, dynamic> toJson() => {
        "plan_code": planCode?.value,
        "status": status,
        "amount": amount,
        "currency": currency,
        "trial_end": trialEnd?.toIso8601String(),
        "current_period_start": currentPeriodStart?.toIso8601String(),
        "current_period_end": currentPeriodEnd?.toIso8601String(),
        "cancel_at_period_end": cancelAtPeriodEnd,
        "canceled_at": canceledAt?.toIso8601String(),
      };
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

import 'dart:convert';

ClaraMessageModel claraMessageModelFromJson(String str) =>
    ClaraMessageModel.fromJson(json.decode(str));
String claraMessageModelToJson(ClaraMessageModel data) =>
    json.encode(data.toJson());

/// How long the typewriter takes to reveal [text]. Shared by the assistant
/// bubble (drives its reveal) and the chat screen (delays a following insight
/// card so the chart appears only after the text finishes). ~32ms per glyph,
/// clamped so short replies still feel deliberate and long ones don't drag.
Duration claraRevealDuration(String text) {
  final glyphs = text.runes.length;
  return Duration(milliseconds: (glyphs * 32).clamp(600, 3400));
}

enum ClaraRole { user, assistant }

enum ClaraMessageType { text, insight }

class ClaraMessageModel {
  final String id;
  final ClaraRole role;
  final ClaraMessageType type;
  final String? text;
  final ClaraInsightModel? insight;
  final DateTime sentAt;

  ClaraMessageModel({
    required this.id,
    required this.role,
    this.type = ClaraMessageType.text,
    this.text,
    this.insight,
    required this.sentAt,
  });

  bool get isUser => role == ClaraRole.user;
  bool get isInsight => type == ClaraMessageType.insight && insight != null;

  /// Converts one backend `ClaraMessageDto` (`{role, content, data, created_at}`)
  /// into 1–2 UI messages: a text bubble for `content`, plus an insight card when
  /// an assistant message carries a structured `data` (expense summary) payload.
  static List<ClaraMessageModel> listFromBackend(Map<String, dynamic> json) {
    final role =
        json["role"] == "user" ? ClaraRole.user : ClaraRole.assistant;
    final content = (json["content"] as String?)?.trim() ?? '';
    final createdAt =
        DateTime.tryParse(json["created_at"] ?? '')?.toLocal() ?? DateTime.now();
    final baseId =
        '${createdAt.microsecondsSinceEpoch}_${role.name}_${content.hashCode}';

    final result = <ClaraMessageModel>[];
    if (content.isNotEmpty) {
      result.add(ClaraMessageModel(
        id: '${baseId}_t',
        role: role,
        text: content,
        sentAt: createdAt,
      ));
    }

    final data = json["data"];
    if (role == ClaraRole.assistant && data is Map<String, dynamic>) {
      final insight = ClaraInsightModel.fromSummary(data);
      if (insight != null) {
        result.add(ClaraMessageModel(
          id: '${baseId}_i',
          role: role,
          type: ClaraMessageType.insight,
          insight: insight,
          sentAt: createdAt,
        ));
      }
    }
    return result;
  }

  factory ClaraMessageModel.fromJson(Map<String, dynamic> json) =>
      ClaraMessageModel(
        id: json["id"],
        role: json["role"] == "user" ? ClaraRole.user : ClaraRole.assistant,
        type: json["type"] == "insight"
            ? ClaraMessageType.insight
            : ClaraMessageType.text,
        text: json["text"],
        insight: json["insight"] != null
            ? ClaraInsightModel.fromJson(json["insight"])
            : null,
        sentAt: json["sentAt"] != null
            ? DateTime.parse(json["sentAt"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "role": role == ClaraRole.user ? "user" : "assistant",
        "type": type == ClaraMessageType.insight ? "insight" : "text",
        "text": text,
        "insight": insight?.toJson(),
        "sentAt": sentAt.toIso8601String(),
      };
}

class ClaraInsightModel {
  final String title;
  final double income;
  final double expense;

  /// Per-month income vs expense — rendered with the same grouped bar chart as
  /// the home screen's Income & Expense section.
  final List<ClaraTrendPoint> trend;

  ClaraInsightModel({
    required this.title,
    required this.income,
    required this.expense,
    required this.trend,
  });

  factory ClaraInsightModel.fromJson(Map<String, dynamic> json) =>
      ClaraInsightModel(
        title: json["title"] ?? "Income and expense",
        income: (json["income"] ?? 0).toDouble(),
        expense: (json["expense"] ?? 0).toDouble(),
        trend: json["trend"] != null
            ? List<ClaraTrendPoint>.from(
                json["trend"].map((x) => ClaraTrendPoint.fromJson(x)))
            : [],
      );

  /// Builds the chart card from the backend's `ExpenseSummaryDto` payload
  /// (the `data` field on an assistant message). Returns null when the payload
  /// isn't a usable summary. Uses the `income_expense_trend` (month → income,
  /// expense) so the chart matches the home dashboard.
  static ClaraInsightModel? fromSummary(Map<String, dynamic> summary) {
    if (!summary.containsKey("total_expense") &&
        !summary.containsKey("monthly_income")) {
      return null;
    }
    final raw = (summary["income_expense_trend"] as List?) ?? const [];
    final trend = raw
        .whereType<Map<String, dynamic>>()
        .map((p) => ClaraTrendPoint(
              month: (p["month"] ?? '').toString(),
              income: _num(p["income"]),
              expense: _num(p["expense"]),
            ))
        .toList();
    return ClaraInsightModel(
      title: (summary["month_label"] ?? "Income and expense").toString(),
      income: _num(summary["monthly_income"]),
      expense: _num(summary["total_expense"]),
      trend: trend,
    );
  }

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "income": income,
        "expense": expense,
        "trend": List<dynamic>.from(trend.map((x) => x.toJson())),
      };
}

class ClaraTrendPoint {
  final String month;
  final double income;
  final double expense;

  ClaraTrendPoint({
    required this.month,
    required this.income,
    required this.expense,
  });

  factory ClaraTrendPoint.fromJson(Map<String, dynamic> json) =>
      ClaraTrendPoint(
        month: json["month"] ?? "",
        income: (json["income"] ?? 0).toDouble(),
        expense: (json["expense"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() =>
      {"month": month, "income": income, "expense": expense};
}

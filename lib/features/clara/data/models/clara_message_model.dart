import 'dart:convert';

ClaraMessageModel claraMessageModelFromJson(String str) =>
    ClaraMessageModel.fromJson(json.decode(str));
String claraMessageModelToJson(ClaraMessageModel data) =>
    json.encode(data.toJson());

/// How long the typewriter takes to reveal [text]. Shared by the assistant
/// bubble (drives its reveal) and the chat screen (delays a following insight
/// card so the chart appears only after the text finishes). ~32ms per glyph,
/// clamped so short replies still feel deliberate and long ones don't drag.
Duration claraRevealDuration(String text) =>
    claraRevealDurationFor(text.runes.length);

/// Same curve, for callers that already know the rendered (markdown-stripped)
/// glyph count and must match the reveal exactly.
Duration claraRevealDurationFor(int glyphs) =>
    Duration(milliseconds: (glyphs * 32).clamp(600, 3400));

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
  static List<ClaraMessageModel> listFromBackend(
    Map<String, dynamic> json, {
    String? precedingUserText,
  }) {
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
      final insight = ClaraInsightModel.fromSummary(
        data,
        questionText: precedingUserText,
        replyText: content,
      );
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

enum ClaraInsightKind { incomeExpense, categoryBreakdown }

/// Keywords that signal the user asked for a per-category spending breakdown
/// rather than the default income vs expense trend. Checked against both the
/// user's question and Clara's own reply, since history rows only carry the
/// latter.
final _categoryBreakdownPattern = RegExp(
  r'categor|breakdown|where.*(money|spending).*(going|go)|which.*(category|categories)',
  caseSensitive: false,
);

class ClaraInsightModel {
  final String title;
  final ClaraInsightKind kind;
  final double income;
  final double expense;

  /// Per-month income vs expense — rendered with the same grouped bar chart as
  /// the home screen's Income & Expense section.
  final List<ClaraTrendPoint> trend;

  /// Per-category spend breakdown — rendered as a horizontal bar list when
  /// [kind] is [ClaraInsightKind.categoryBreakdown].
  final List<ClaraCategorySlice> categories;

  ClaraInsightModel({
    required this.title,
    this.kind = ClaraInsightKind.incomeExpense,
    this.income = 0,
    this.expense = 0,
    this.trend = const [],
    this.categories = const [],
  });

  factory ClaraInsightModel.fromJson(Map<String, dynamic> json) =>
      ClaraInsightModel(
        title: json["title"] ?? "Income and expense",
        kind: json["kind"] == "categoryBreakdown"
            ? ClaraInsightKind.categoryBreakdown
            : ClaraInsightKind.incomeExpense,
        income: (json["income"] ?? 0).toDouble(),
        expense: (json["expense"] ?? 0).toDouble(),
        trend: json["trend"] != null
            ? List<ClaraTrendPoint>.from(
                json["trend"].map((x) => ClaraTrendPoint.fromJson(x)))
            : [],
        categories: json["categories"] != null
            ? List<ClaraCategorySlice>.from(
                json["categories"].map((x) => ClaraCategorySlice.fromJson(x)))
            : [],
      );

  /// Builds the chart card from the backend's `ExpenseSummaryDto` payload
  /// (the `data` field on an assistant message). Returns null when the payload
  /// isn't a usable summary.
  ///
  /// The payload always carries both `categories` and `income_expense_trend` —
  /// the backend doesn't say which the user wanted, so we infer it from what
  /// was actually asked ([questionText], falling back to Clara's own
  /// [replyText] for history rows where the question isn't in scope).
  static ClaraInsightModel? fromSummary(
    Map<String, dynamic> summary, {
    String? questionText,
    String? replyText,
  }) {
    if (!summary.containsKey("total_expense") &&
        !summary.containsKey("monthly_income")) {
      return null;
    }

    final categoriesRaw = (summary["categories"] as List?) ?? const [];
    final categories = categoriesRaw
        .whereType<Map<String, dynamic>>()
        .map((c) => ClaraCategorySlice.fromJson(c))
        .toList();

    final wantsBreakdown = categories.isNotEmpty &&
        (_categoryBreakdownPattern.hasMatch(questionText ?? '') ||
            _categoryBreakdownPattern.hasMatch(replyText ?? ''));

    if (wantsBreakdown) {
      return ClaraInsightModel(
        title: (summary["month_label"] ?? "Spending by category").toString(),
        kind: ClaraInsightKind.categoryBreakdown,
        expense: _num(summary["total_expense"]),
        categories: categories,
      );
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
      kind: ClaraInsightKind.incomeExpense,
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
        "kind": kind == ClaraInsightKind.categoryBreakdown
            ? "categoryBreakdown"
            : "incomeExpense",
        "income": income,
        "expense": expense,
        "trend": List<dynamic>.from(trend.map((x) => x.toJson())),
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class ClaraCategorySlice {
  final String name;
  final double amount;
  final double pctOfTotal;
  final int transactionCount;

  const ClaraCategorySlice({
    required this.name,
    required this.amount,
    required this.pctOfTotal,
    this.transactionCount = 0,
  });

  factory ClaraCategorySlice.fromJson(Map<String, dynamic> json) =>
      ClaraCategorySlice(
        name: (json["name"] ?? '').toString(),
        amount: ClaraInsightModel._num(json["amount"]),
        pctOfTotal: ClaraInsightModel._num(json["pct_of_total"]),
        transactionCount: (json["transaction_count"] ?? 0) is int
            ? json["transaction_count"] ?? 0
            : int.tryParse(json["transaction_count"].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "amount": amount,
        "pct_of_total": pctOfTotal,
        "transaction_count": transactionCount,
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

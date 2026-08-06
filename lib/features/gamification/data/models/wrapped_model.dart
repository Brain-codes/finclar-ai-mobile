import 'dart:convert';

WrappedModel wrappedModelFromJson(String str) =>
    WrappedModel.fromJson(json.decode(str));

String wrappedModelToJson(WrappedModel data) => json.encode(data.toJson());

/// `GET /wrapped?year=&month=` — the recap payload for a single month.
///
/// Every section carries its own backend-written `headline`. Render those
/// verbatim; do not compose replacement copy on the client.
class WrappedModel {
  final int year;
  final int month;
  final DateTime? startDate;
  final DateTime? endDate;
  final String symbol;
  final WrappedCover cover;
  final WrappedIncomeExpense incomeVsExpense;
  final WrappedSpendingBreakdown spendingBreakdown;

  /// Null for a year with no expenses.
  final WrappedTopCategory? topCategory;
  final WrappedSavings savings;
  final WrappedPersonality personality;
  final WrappedTip tip;
  final WrappedBadge badge;
  final WrappedSharePassport sharePassport;

  const WrappedModel({
    required this.year,
    required this.month,
    this.startDate,
    this.endDate,
    required this.symbol,
    required this.cover,
    required this.incomeVsExpense,
    required this.spendingBreakdown,
    this.topCategory,
    required this.savings,
    required this.personality,
    required this.tip,
    required this.badge,
    required this.sharePassport,
  });

  factory WrappedModel.fromJson(Map<String, dynamic> json) => WrappedModel(
    year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
    month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
    startDate: _toDate(json['start_date']),
    endDate: _toDate(json['end_date']),
    symbol: json['symbol'] as String? ?? '',
    cover: WrappedCover.fromJson(_map(json['cover'])),
    incomeVsExpense: WrappedIncomeExpense.fromJson(
      _map(json['income_vs_expense']),
    ),
    spendingBreakdown: WrappedSpendingBreakdown.fromJson(
      _map(json['spending_breakdown']),
    ),
    topCategory: json['top_category'] != null
        ? WrappedTopCategory.fromJson(_map(json['top_category']))
        : null,
    savings: WrappedSavings.fromJson(_map(json['savings'])),
    personality: WrappedPersonality.fromJson(_map(json['personality'])),
    tip: WrappedTip.fromJson(_map(json['tip'])),
    badge: WrappedBadge.fromJson(_map(json['badge'])),
    sharePassport: WrappedSharePassport.fromJson(_map(json['share_passport'])),
  );

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'symbol': symbol,
    'cover': cover.toJson(),
    'income_vs_expense': incomeVsExpense.toJson(),
    'spending_breakdown': spendingBreakdown.toJson(),
    'top_category': topCategory?.toJson(),
    'savings': savings.toJson(),
    'personality': personality.toJson(),
    'tip': tip.toJson(),
    'badge': badge.toJson(),
    'share_passport': sharePassport.toJson(),
  };
}

class WrappedCover {
  final int year;
  final int month;
  final String username;
  final String headline;

  const WrappedCover({
    required this.year,
    required this.month,
    required this.username,
    required this.headline,
  });

  factory WrappedCover.fromJson(Map<String, dynamic> json) => WrappedCover(
    year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
    month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
    username: json['username'] as String? ?? '',
    headline: json['headline'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'username': username,
    'headline': headline,
  };
}

class WrappedIncomeExpense {
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;
  final String headline;

  const WrappedIncomeExpense({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
    required this.headline,
  });

  factory WrappedIncomeExpense.fromJson(Map<String, dynamic> json) =>
      WrappedIncomeExpense(
        totalIncome: _toDouble(json['total_income']),
        totalExpenses: _toDouble(json['total_expenses']),
        netBalance: _toDouble(json['net_balance']),
        headline: json['headline'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'total_income': totalIncome,
    'total_expenses': totalExpenses,
    'net_balance': netBalance,
    'headline': headline,
  };
}

class WrappedSpendingBreakdown {
  final double totalExpenses;
  final List<WrappedCategoryShare> categories;
  final String headline;

  const WrappedSpendingBreakdown({
    required this.totalExpenses,
    required this.categories,
    required this.headline,
  });

  factory WrappedSpendingBreakdown.fromJson(Map<String, dynamic> json) =>
      WrappedSpendingBreakdown(
        totalExpenses: _toDouble(json['total_expenses']),
        categories: (json['categories'] as List<dynamic>? ?? [])
            .map((e) => WrappedCategoryShare.fromJson(_map(e)))
            .toList(),
        headline: json['headline'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'total_expenses': totalExpenses,
    'categories': categories.map((e) => e.toJson()).toList(),
    'headline': headline,
  };
}

class WrappedCategoryShare {
  final String name;
  final String? icon;
  final double amount;
  final double percentage;

  const WrappedCategoryShare({
    required this.name,
    this.icon,
    required this.amount,
    required this.percentage,
  });

  factory WrappedCategoryShare.fromJson(Map<String, dynamic> json) =>
      WrappedCategoryShare(
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String?,
        amount: _toDouble(json['amount']),
        percentage: _toDouble(json['percentage']),
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'amount': amount,
    'percentage': percentage,
  };
}

class WrappedTopCategory {
  final String name;
  final String? icon;
  final double amount;
  final double percentage;
  final String headline;

  const WrappedTopCategory({
    required this.name,
    this.icon,
    required this.amount,
    required this.percentage,
    required this.headline,
  });

  factory WrappedTopCategory.fromJson(Map<String, dynamic> json) =>
      WrappedTopCategory(
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String?,
        amount: _toDouble(json['amount']),
        percentage: _toDouble(json['percentage']),
        headline: json['headline'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'amount': amount,
    'percentage': percentage,
    'headline': headline,
  };
}

class WrappedSavings {
  final double savingsRate;
  final double totalSaved;
  final String headline;
  final List<WrappedMonthlySavings> monthlyTrend;

  const WrappedSavings({
    required this.savingsRate,
    required this.totalSaved,
    required this.headline,
    required this.monthlyTrend,
  });

  factory WrappedSavings.fromJson(Map<String, dynamic> json) => WrappedSavings(
    savingsRate: _toDouble(json['savings_rate']),
    totalSaved: _toDouble(json['total_saved']),
    headline: json['headline'] as String? ?? '',
    monthlyTrend: (json['monthly_trend'] as List<dynamic>? ?? [])
        .map((e) => WrappedMonthlySavings.fromJson(_map(e)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'savings_rate': savingsRate,
    'total_saved': totalSaved,
    'headline': headline,
    'monthly_trend': monthlyTrend.map((e) => e.toJson()).toList(),
  };
}

class WrappedMonthlySavings {
  final int year;

  /// 1–12.
  final int month;
  final double income;
  final double expenses;
  final double netSaved;

  const WrappedMonthlySavings({
    required this.year,
    required this.month,
    required this.income,
    required this.expenses,
    required this.netSaved,
  });

  factory WrappedMonthlySavings.fromJson(Map<String, dynamic> json) =>
      WrappedMonthlySavings(
        year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
        month: (json['month'] as num?)?.toInt() ?? 1,
        income: _toDouble(json['income']),
        expenses: _toDouble(json['expenses']),
        netSaved: _toDouble(json['net_saved']),
      );

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'income': income,
    'expenses': expenses,
    'net_saved': netSaved,
  };
}

class WrappedPersonality {
  final String key;
  final String name;
  final String description;

  const WrappedPersonality({
    required this.key,
    required this.name,
    required this.description,
  });

  factory WrappedPersonality.fromJson(Map<String, dynamic> json) =>
      WrappedPersonality(
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'description': description,
  };
}

class WrappedTip {
  final String title;
  final String body;

  const WrappedTip({required this.title, required this.body});

  factory WrappedTip.fromJson(Map<String, dynamic> json) => WrappedTip(
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'title': title, 'body': body};
}

class WrappedBadge {
  final String key;
  final String name;
  final String headline;
  final String description;
  final int monthsOnTrack;
  final int monthsTracked;

  const WrappedBadge({
    required this.key,
    required this.name,
    required this.headline,
    required this.description,
    required this.monthsOnTrack,
    required this.monthsTracked,
  });

  factory WrappedBadge.fromJson(Map<String, dynamic> json) => WrappedBadge(
    key: json['key'] as String? ?? '',
    name: json['name'] as String? ?? '',
    headline: json['headline'] as String? ?? '',
    description: json['description'] as String? ?? '',
    monthsOnTrack: (json['months_on_track'] as num?)?.toInt() ?? 0,
    monthsTracked: (json['months_tracked'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'headline': headline,
    'description': description,
    'months_on_track': monthsOnTrack,
    'months_tracked': monthsTracked,
  };
}

class WrappedSharePassport {
  final String username;
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpenses;
  final double totalSaved;
  final String? topCategory;
  final String personalityName;
  final String badgeName;

  const WrappedSharePassport({
    required this.username,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSaved,
    this.topCategory,
    required this.personalityName,
    required this.badgeName,
  });

  factory WrappedSharePassport.fromJson(Map<String, dynamic> json) =>
      WrappedSharePassport(
        username: json['username'] as String? ?? '',
        year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
        month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
        totalIncome: _toDouble(json['total_income']),
        totalExpenses: _toDouble(json['total_expenses']),
        totalSaved: _toDouble(json['total_saved']),
        topCategory: json['top_category'] as String?,
        personalityName: json['personality_name'] as String? ?? '',
        badgeName: json['badge_name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'username': username,
    'year': year,
    'month': month,
    'total_income': totalIncome,
    'total_expenses': totalExpenses,
    'total_saved': totalSaved,
    'top_category': topCategory,
    'personality_name': personalityName,
    'badge_name': badgeName,
  };
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

DateTime? _toDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

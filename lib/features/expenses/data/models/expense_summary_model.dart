import 'dart:convert';

ExpenseSummaryModel expenseSummaryModelFromJson(String str) =>
    ExpenseSummaryModel.fromJson(json.decode(str));
String expenseSummaryModelToJson(ExpenseSummaryModel data) =>
    json.encode(data.toJson());

class ExpenseSummaryModel {
  final String monthLabel;
  final double totalExpense;
  final double? momChangePct;
  final String? momDirection;
  final double monthlyIncome;
  final List<CategorySummaryModel> categories;
  final List<MonthlyTrendPointModel> monthlyTrend;
  final List<IncomeExpenseTrendPointModel> incomeExpenseTrend;

  ExpenseSummaryModel({
    required this.monthLabel,
    required this.totalExpense,
    this.momChangePct,
    this.momDirection,
    required this.monthlyIncome,
    required this.categories,
    required this.monthlyTrend,
    required this.incomeExpenseTrend,
  });

  double get balance => monthlyIncome - totalExpense;

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) =>
      ExpenseSummaryModel(
        monthLabel: json["month_label"] ?? '',
        totalExpense: (json["total_expense"] as num?)?.toDouble() ?? 0,
        momChangePct: (json["mom_change_pct"] as num?)?.toDouble(),
        momDirection: json["mom_direction"],
        monthlyIncome: (json["monthly_income"] as num?)?.toDouble() ?? 0,
        categories: json["categories"] != null
            ? List<CategorySummaryModel>.from(
                json["categories"].map((x) => CategorySummaryModel.fromJson(x)))
            : [],
        monthlyTrend: json["monthly_trend"] != null
            ? List<MonthlyTrendPointModel>.from(json["monthly_trend"]
                .map((x) => MonthlyTrendPointModel.fromJson(x)))
            : [],
        incomeExpenseTrend: json["income_expense_trend"] != null
            ? List<IncomeExpenseTrendPointModel>.from(json["income_expense_trend"]
                .map((x) => IncomeExpenseTrendPointModel.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "month_label": monthLabel,
        "total_expense": totalExpense,
        "mom_change_pct": momChangePct,
        "mom_direction": momDirection,
        "monthly_income": monthlyIncome,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "monthly_trend": List<dynamic>.from(monthlyTrend.map((x) => x.toJson())),
        "income_expense_trend":
            List<dynamic>.from(incomeExpenseTrend.map((x) => x.toJson())),
      };
}

class CategorySummaryModel {
  final String name;
  final double amount;
  final int transactionCount;
  final double pctOfTotal;

  CategorySummaryModel({
    required this.name,
    required this.amount,
    required this.transactionCount,
    required this.pctOfTotal,
  });

  factory CategorySummaryModel.fromJson(Map<String, dynamic> json) =>
      CategorySummaryModel(
        name: json["name"] ?? '',
        amount: (json["amount"] as num?)?.toDouble() ?? 0,
        transactionCount: json["transaction_count"] ?? 0,
        pctOfTotal: (json["pct_of_total"] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "amount": amount,
        "transaction_count": transactionCount,
        "pct_of_total": pctOfTotal,
      };
}

class MonthlyTrendPointModel {
  final String month;
  final int year;
  final double total;

  MonthlyTrendPointModel({
    required this.month,
    required this.year,
    required this.total,
  });

  factory MonthlyTrendPointModel.fromJson(Map<String, dynamic> json) =>
      MonthlyTrendPointModel(
        month: json["month"] ?? '',
        year: json["year"] ?? 0,
        total: (json["total"] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "month": month,
        "year": year,
        "total": total,
      };
}

class IncomeExpenseTrendPointModel {
  final String month;
  final int year;
  final double income;
  final double expense;

  IncomeExpenseTrendPointModel({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
  });

  factory IncomeExpenseTrendPointModel.fromJson(Map<String, dynamic> json) =>
      IncomeExpenseTrendPointModel(
        month: json["month"] ?? '',
        year: json["year"] ?? 0,
        income: (json["income"] as num?)?.toDouble() ?? 0,
        expense: (json["expense"] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "month": month,
        "year": year,
        "income": income,
        "expense": expense,
      };
}

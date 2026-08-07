import Foundation

enum FinclarWidgetKeys {
    static let appGroup = "group.com.finclar.finclarAi"

    static let monthLabel = "widget_month_label"
    static let totalExpense = "widget_total_expense"
    static let monthlyIncome = "widget_monthly_income"
    static let currencySymbol = "widget_currency_symbol"
    static let topCategoryName = "widget_top_category_name"
    static let topCategoryAmount = "widget_top_category_amount"
    static let updatedAt = "widget_updated_at"
}

struct FinclarWidgetData {
    let monthLabel: String
    let totalExpense: Double
    let monthlyIncome: Double
    let currencySymbol: String
    let topCategoryName: String?
    let topCategoryAmount: Double
    let updatedAt: Date?
    let hasData: Bool

    var balance: Double { monthlyIncome - totalExpense }

    /// Share of income already spent, clamped so an overspend still renders a full bar.
    var spentFraction: Double {
        guard monthlyIncome > 0 else { return 0 }
        return min(max(totalExpense / monthlyIncome, 0), 1)
    }

    var isOverspent: Bool { monthlyIncome > 0 && totalExpense > monthlyIncome }

    static let placeholder = FinclarWidgetData(
        monthLabel: "This month",
        totalExpense: 148_500,
        monthlyIncome: 450_000,
        currencySymbol: "₦",
        topCategoryName: "Food",
        topCategoryAmount: 52_300,
        updatedAt: Date(),
        hasData: true
    )

    static let empty = FinclarWidgetData(
        monthLabel: "This month",
        totalExpense: 0,
        monthlyIncome: 0,
        currencySymbol: "",
        topCategoryName: nil,
        topCategoryAmount: 0,
        updatedAt: nil,
        hasData: false
    )

    static func load() -> FinclarWidgetData {
        guard let defaults = UserDefaults(suiteName: FinclarWidgetKeys.appGroup)
        else { return .empty }

        let stamp = defaults.double(forKey: FinclarWidgetKeys.updatedAt)
        guard stamp > 0 else { return .empty }

        let category = defaults.string(forKey: FinclarWidgetKeys.topCategoryName)

        return FinclarWidgetData(
            monthLabel: defaults.string(forKey: FinclarWidgetKeys.monthLabel) ?? "This month",
            totalExpense: defaults.double(forKey: FinclarWidgetKeys.totalExpense),
            monthlyIncome: defaults.double(forKey: FinclarWidgetKeys.monthlyIncome),
            currencySymbol: defaults.string(forKey: FinclarWidgetKeys.currencySymbol) ?? "",
            topCategoryName: (category?.isEmpty ?? true) ? nil : category,
            topCategoryAmount: defaults.double(forKey: FinclarWidgetKeys.topCategoryAmount),
            updatedAt: Date(timeIntervalSince1970: stamp / 1000),
            hasData: true
        )
    }

    func formatted(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: amount)) ?? "0"
        return currencySymbol + number
    }
}

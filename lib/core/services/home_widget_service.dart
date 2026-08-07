import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../../features/expenses/data/models/expense_summary_model.dart';
import 'logger_service.dart';

/// The only place the app talks to `home_widget`. Swapping the package or
/// adding Android support happens here, not at the call sites.
class HomeWidgetService {
  static const String _appGroupId = 'group.com.finclar.finclarAi';
  static const String _iosWidgetName = 'FinclarSpendingWidget';

  static const String _kMonthLabel = 'widget_month_label';
  static const String _kTotalExpense = 'widget_total_expense';
  static const String _kMonthlyIncome = 'widget_monthly_income';
  static const String _kCurrencySymbol = 'widget_currency_symbol';
  static const String _kTopCategoryName = 'widget_top_category_name';
  static const String _kTopCategoryAmount = 'widget_top_category_amount';
  static const String _kUpdatedAt = 'widget_updated_at';

  static bool get _supported => Platform.isIOS;

  static Future<void> init() async {
    if (!_supported) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (e, st) {
      Log.e('[HomeWidget] Could not set app group', error: e, stackTrace: st);
    }
  }

  /// Pushes the latest dashboard numbers to the home screen widget.
  /// Safe to call on every dashboard refresh — failures are logged, never thrown.
  static Future<void> updateSpending(
    ExpenseSummaryModel summary, {
    required String currencySymbol,
  }) async {
    if (!_supported) return;

    try {
      final top = summary.categories.isEmpty
          ? null
          : summary.categories
              .reduce((a, b) => a.amount >= b.amount ? a : b);

      await Future.wait([
        HomeWidget.saveWidgetData<String>(_kMonthLabel, summary.monthLabel),
        HomeWidget.saveWidgetData<double>(_kTotalExpense, summary.totalExpense),
        HomeWidget.saveWidgetData<double>(_kMonthlyIncome, summary.monthlyIncome),
        HomeWidget.saveWidgetData<String>(_kCurrencySymbol, currencySymbol),
        HomeWidget.saveWidgetData<String>(_kTopCategoryName, top?.name ?? ''),
        HomeWidget.saveWidgetData<double>(_kTopCategoryAmount, top?.amount ?? 0),
        HomeWidget.saveWidgetData<double>(
          _kUpdatedAt,
          DateTime.now().millisecondsSinceEpoch.toDouble(),
        ),
      ]);

      await HomeWidget.updateWidget(iOSName: _iosWidgetName);
      Log.d('[HomeWidget] Pushed ${summary.monthLabel} spending to widget');
    } catch (e, st) {
      Log.e('[HomeWidget] Update failed', error: e, stackTrace: st);
    }
  }

  /// Wipes the widget back to its empty state — call on logout.
  static Future<void> clear() async {
    if (!_supported) return;
    try {
      await HomeWidget.saveWidgetData<double>(_kUpdatedAt, 0);
      await HomeWidget.saveWidgetData<String>(_kMonthLabel, '');
      await HomeWidget.saveWidgetData<double>(_kTotalExpense, 0);
      await HomeWidget.saveWidgetData<double>(_kMonthlyIncome, 0);
      await HomeWidget.saveWidgetData<String>(_kTopCategoryName, '');
      await HomeWidget.saveWidgetData<double>(_kTopCategoryAmount, 0);
      await HomeWidget.updateWidget(iOSName: _iosWidgetName);
    } catch (e, st) {
      Log.e('[HomeWidget] Clear failed', error: e, stackTrace: st);
    }
  }
}

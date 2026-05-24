import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../data/models/expense_model.dart';
import 'expense_tile.dart';

class ExpenseList extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const ExpenseList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<ExpenseModel>>{};
    for (final e in expenses) {
      final key = DateFormat('MMM d, yyyy').format(e.date);
      groups.putIfAbsent(key, () => []).add(e);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.base,
      ),
      child: Column(
        children: groups.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusSheet,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    entry.key,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontSize: 12,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ),
                ...entry.value.map(
                  (e) => ExpenseTile(
                    expense: e,
                    showDivider: e != entry.value.last,
                    onTap: () => context.push(RouteNames.expenseDetail, extra: e),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

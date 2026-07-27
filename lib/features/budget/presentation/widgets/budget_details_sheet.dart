import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';
import 'budget_delete_sheet.dart';

Future<void> showBudgetDetailsSheet(
  BuildContext context, {
  required double currentAmount,
  required String budgetAmount,
  required String allocated,
  required String unallocated,
  required String allocatedSpent,
  required String allocatedRemaining,
  required String startDate,
  required String endDate,
  Future<bool> Function()? onDeleted,
}) {
  return showAppSheet(
    context,
    title: 'Budget details',
    children: [
      _DetailsCard(
        children: [
          _DetailRow(
            label: 'Budget amount',
            value: budgetAmount,
            hasEdit: true,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              context.push(RouteNames.createBudget, extra: ('Increase budget', currentAmount));
            },
          ),
          _Divider(),
          _DetailRow(label: 'Budget allocated', value: allocated),
          _Divider(),
          _DetailRow(label: 'Budget unallocated', value: unallocated),
          _Divider(),
          _DetailRow(label: 'Allocated spent', value: allocatedSpent),
          _Divider(),
          _DetailRow(label: 'Allocated remaining', value: allocatedRemaining),
          _Divider(),
          _DetailRow(label: 'Start date', value: startDate, hasEdit: true),
          _Divider(),
          _DetailRow(label: 'End date', value: endDate),
        ],
      ),
      const SizedBox(height: AppSpacing.xl),
      _DeleteRow(onDeleted: onDeleted),
    ],
  );
}

class _DetailsCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool hasEdit;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.label,
    required this.value,
    this.hasEdit = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textQuaternary,
                fontSize: 14,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
            if (hasEdit) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(AppIcons.edit, size: 14, color: context.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.borderColor,
      indent: AppSpacing.base,
      endIndent: AppSpacing.base,
    );
  }
}

class _DeleteRow extends StatelessWidget {
  final Future<bool> Function()? onDeleted;
  const _DeleteRow({this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDeleted == null
          ? null
          : () async {
              final navigator = Navigator.of(context, rootNavigator: true);
              navigator.pop();
              await showBudgetDeleteSheet(
                navigator.context,
                onConfirm: onDeleted!,
              );
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.delete, size: 18, color: AppColors.error),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Delete budget',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.error,
              fontSize: 14,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
        ],
      ),
    );
  }
}

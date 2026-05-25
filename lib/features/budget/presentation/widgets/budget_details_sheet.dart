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
  required String budgetAmount,
  required String allocated,
  required String unallocated,
  required String allocatedSpent,
  required String allocatedRemaining,
  required String startDate,
  required String endDate,
  VoidCallback? onDeleted,
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
            hasChevron: true,
            onTap: () {
              Navigator.of(context).pop();
              context.push(RouteNames.createBudget, extra: 'Increase budget');
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
          _DetailRow(label: 'Start date', value: startDate, hasChevron: true),
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
  final bool hasChevron;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.label,
    required this.value,
    this.hasChevron = false,
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
          if (hasChevron) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(AppIcons.chevronRight, size: 14, color: context.textSecondary),
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
  final VoidCallback? onDeleted;
  const _DeleteRow({this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop();
        final confirmed = await showBudgetDeleteSheet(context);
        if (confirmed == true) onDeleted?.call();
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

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'budget_category_sheet.dart';

Future<void> showBudgetAllocationSheet(
  BuildContext context, {
  required double amountLeft,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (_) => _AllocationSheet(amountLeft: amountLeft),
  );
}

class _AllocationSheet extends StatefulWidget {
  final double amountLeft;
  const _AllocationSheet({required this.amountLeft});

  @override
  State<_AllocationSheet> createState() => _AllocationSheetState();
}

class _AllocationSheetState extends State<_AllocationSheet> {
  String? _category;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _category != null && _amountController.text.trim().isNotEmpty;

  String _formatAmount(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.xxxl + keyboardHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom header: amount + subtitle + close button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₦${_formatAmount(widget.amountLeft)}',
                      style: AppTypography.headingMedium.copyWith(
                        color: context.textPrimary,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Amount left to allocate',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderStrong),
                  ),
                  child: Icon(AppIcons.close, size: 14, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Category label + input
          Text(
            'Category',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () async {
              final result = await showBudgetCategorySheet(context);
              if (result != null) setState(() => _category = result);
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: AppRadius.radiusInput,
                border: Border.all(color: context.inputBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _category ?? 'Select category',
                      style: AppTypography.bodyMedium.copyWith(
                        color: _category != null
                            ? context.textPrimary
                            : context.inputPlaceholder,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(AppIcons.chevronRight, size: 16, color: context.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Amount input + helper
          AppTextField(
            label: 'Amount',
            hint: 'Enter amount',
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '20% of total expense',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GestureDetector(
              onTap: _canContinue ? () => Navigator.of(context).pop() : null,
              child: Container(
                decoration: BoxDecoration(
                  color: _canContinue ? AppColors.primary : context.surfaceVariant,
                  borderRadius: AppRadius.radiusFull,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Continue',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _canContinue ? AppColors.white : context.textSecondary,
                    fontSize: 16,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

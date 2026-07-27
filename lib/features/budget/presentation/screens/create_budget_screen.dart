import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_keypad.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../providers/budget_providers.dart';

/// Reusable screen for both "Create budget" and "Increase budget" flows.
/// Pass [title] to differentiate. Uses the same keypad UI as IncomeSetupScreen.
class CreateBudgetScreen extends ConsumerStatefulWidget {
  final String title;
  final double? currentAmount;

  const CreateBudgetScreen({super.key, this.title = 'Create budget', this.currentAmount});

  @override
  ConsumerState<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends ConsumerState<CreateBudgetScreen> {
  final _keypad = AppKeypadController();
  bool _isSubmitting = false;

  bool get _isIncrease => widget.currentAmount != null;

  @override
  void dispose() {
    _keypad.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final amount = _keypad.value;
    if (amount == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final notifier = ref.read(budgetProvider.notifier);
      if (_isIncrease) {
        await notifier.updateAmount(amount);
      } else {
        await notifier.create(amountAllocated: amount);
      }
      if (mounted) context.pop();
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackbar.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => context.pop()),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title,
                        style: AppTypography.headingMedium.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (_isIncrease) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _CurrentBudgetCard(currentAmount: widget.currentAmount!),
                  ],
                  const Spacer(),
                  ListenableBuilder(
                    listenable: _keypad,
                    builder: (context, _) {
                      final symbol = ref.read(currencySymbolProvider);
                      final typed = _keypad.value;
                      final newTotal = _isIncrease && typed != null
                          ? widget.currentAmount! + typed
                          : null;
                      return Column(
                        children: [
                          Text(
                            _isIncrease ? 'Add amount' : 'Budget amount',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _keypad.displayAmount,
                            style: AppTypography.amountLarge.copyWith(
                              fontSize: 36,
                              fontVariations: const [FontVariation('wght', 600)],
                              color: _keypad.hasValidAmount
                                  ? context.textQuaternary
                                  : context.textSecondary,
                            ),
                          ),
                          if (newTotal != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryMuted,
                                borderRadius: BorderRadius.circular(AppSpacing.base),
                              ),
                              child: Text(
                                'New total: ${formatCurrency(newTotal, symbol, abbreviate: false, withCommas: true)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontVariations: const [FontVariation('wght', 500)],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  AppKeypad(controller: _keypad),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              child: ListenableBuilder(
                listenable: _keypad,
                builder: (context, _) => AppButton(
                  label: 'Continue',
                  onTap: _keypad.hasValidAmount ? _onContinue : null,
                  isLoading: _isSubmitting,
                  height: 52,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentBudgetCard extends ConsumerWidget {
  final double currentAmount;
  const _CurrentBudgetCard({required this.currentAmount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.base),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current budget',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              formatCurrency(currentAmount, symbol, abbreviate: false, withCommas: true),
              style: AppTypography.bodyMedium.copyWith(
                color: context.textQuaternary,
                fontSize: 18,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.back, size: 20, color: context.textQuaternary),
          ),
        ),
      ),
    );
  }
}

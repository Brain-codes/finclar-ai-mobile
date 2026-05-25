import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_keypad.dart';

/// Reusable screen for both "Create budget" and "Increase budget" flows.
/// Pass [title] to differentiate. Uses the same keypad UI as IncomeSetupScreen.
class CreateBudgetScreen extends StatefulWidget {
  final String title;

  const CreateBudgetScreen({super.key, this.title = 'Create budget'});

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _keypad = AppKeypadController();

  @override
  void dispose() {
    _keypad.dispose();
    super.dispose();
  }

  void _onContinue() {
    final amount = _keypad.value;
    if (amount == null) return;
    // TODO: persist budget amount via provider
    context.pop();
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
                  const Spacer(),
                  ListenableBuilder(
                    listenable: _keypad,
                    builder: (context, _) => Text(
                      _keypad.displayAmount,
                      style: AppTypography.amountLarge.copyWith(
                        fontSize: 32,
                        fontVariations: const [FontVariation('wght', 600)],
                        color: _keypad.hasValidAmount
                            ? context.textQuaternary
                            : context.textSecondary,
                      ),
                    ),
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

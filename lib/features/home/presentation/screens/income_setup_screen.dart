import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_keypad.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../widgets/income_details_sheet.dart';

class IncomeSetupScreen extends StatefulWidget {
  const IncomeSetupScreen({super.key});

  @override
  State<IncomeSetupScreen> createState() => _IncomeSetupScreenState();
}

class _IncomeSetupScreenState extends State<IncomeSetupScreen> {
  final _keypad = AppKeypadController();

  @override
  void dispose() {
    _keypad.dispose();
    super.dispose();
  }

  void _onContinue() {
    final amount = _keypad.value;
    if (amount == null) return;
    showIncomeDetailsSheet(context, amount: amount);
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
                        'Add income',
                        style: AppTypography.headingMedium.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Flexible(child: SizedBox()),
                  ListenableBuilder(
                    listenable: _keypad,
                    builder: (context, _) => Text(
                      _keypad.displayAmount,
                      style: AppTypography.amountLarge.copyWith(
                        fontSize: 32,
                        fontVariations: const [FontVariation('wght', 600)],
                        color: _keypad.hasValidAmount
                            ? context.textQuaternary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Flexible(child: SizedBox()),
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

// ─── Top bar ─────────────────────────────────────────────────────────────────

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

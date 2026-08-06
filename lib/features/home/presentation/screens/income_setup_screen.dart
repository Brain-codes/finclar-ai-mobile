import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_to_words.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_keypad.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../providers/income_setup_provider.dart';
import '../widgets/income_details_sheet.dart';

class IncomeSetupScreen extends ConsumerStatefulWidget {
  const IncomeSetupScreen({super.key});

  @override
  ConsumerState<IncomeSetupScreen> createState() => _IncomeSetupScreenState();
}

class _IncomeSetupScreenState extends ConsumerState<IncomeSetupScreen> {
  final _keypad = AppKeypadController();
  bool _prefilled = false;

  @override
  void dispose() {
    _keypad.dispose();
    super.dispose();
  }

  void _onContinue() {
    final amount = _keypad.value;
    if (amount == null) return;
    showIncomeDetailsSheet(
      context,
      amount: amount,
      existing: ref.read(incomeProvider).valueOrNull,
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = ref.watch(incomeProvider).valueOrNull;
    final currencyCode =
        ref.watch(appConfigProvider).valueOrNull?.currencyCode ?? 'NGN';
    _keypad.setSymbol(ref.watch(currencySymbolProvider));

    // Seeds the keypad once, the first time income resolves — re-seeding on
    // every build would fight the user's own typing.
    if (!_prefilled && existing != null) {
      _prefilled = true;
      _keypad.setAmount(existing.amount);
    }

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => context.pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'Add income' : 'Edit income',
                    style: AppTypography.headingMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    existing == null
                        ? 'How much do you earn?'
                        : 'Update what you earn',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // The amount block gets the whole middle of the screen and centres
            // in it, so the title above and keypad below always have air
            // between them regardless of device height.
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: ListenableBuilder(
                    listenable: _keypad,
                    builder: (context, _) => _AmountDisplay(
                      amount: _keypad.displayAmount,
                      words: amountInWords(
                        _keypad.value ?? 0,
                        currencyCode: currencyCode,
                      ),
                      isActive: _keypad.hasValidAmount,
                    ),
                  ),
                ),
              ),
            ),
            AppKeypad(controller: _keypad),
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

// ─── Amount display ──────────────────────────────────────────────────────────

class _AmountDisplay extends StatelessWidget {
  final String amount;
  final String words;
  final bool isActive;

  const _AmountDisplay({
    required this.amount,
    required this.words,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            maxLines: 1,
            style: AppTypography.amountLarge.copyWith(
              fontSize: 40,
              fontVariations: const [FontVariation('wght', 600)],
              color: isActive ? context.textQuaternary : context.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Reserved height so the layout doesn't jump the moment the first
        // digit is typed and the words appear.
        SizedBox(
          height: 40,
          child: AnimatedOpacity(
            opacity: words.isEmpty ? 0 : 1,
            duration: AppConstants.animFast,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                words,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
        ),
      ],
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

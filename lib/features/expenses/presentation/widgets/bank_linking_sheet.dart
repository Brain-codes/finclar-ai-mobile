import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/bank_model.dart';

enum _LinkingState { inProgress, failed }

/// Shows the bank linking progress sheet.
/// [onLink] is called to perform the actual link; it should return the linked [BankModel].
/// Returns the linked [BankModel] on success, or null if cancelled/failed.
Future<BankModel?> showBankLinkingSheet(
  BuildContext context, {
  required String bankName,
  required Future<BankModel> Function() onLink,
}) {
  return showModalBottomSheet<BankModel>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (_) => _BankLinkingSheet(
      bankName: bankName,
      onLink: onLink,
    ),
  );
}

class _BankLinkingSheet extends StatefulWidget {
  final String bankName;
  final Future<BankModel> Function() onLink;

  const _BankLinkingSheet({
    required this.bankName,
    required this.onLink,
  });

  @override
  State<_BankLinkingSheet> createState() => _BankLinkingSheetState();
}

class _BankLinkingSheetState extends State<_BankLinkingSheet> {
  _LinkingState _state = _LinkingState.inProgress;

  @override
  void initState() {
    super.initState();
    _startLinking();
  }

  Future<void> _startLinking() async {
    setState(() => _state = _LinkingState.inProgress);
    try {
      final bank = await widget.onLink();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(bank);
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _LinkingState.failed);
    }
  }

  void _retry() => _startLinking();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.xl,
          AppSpacing.screenPadding,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetCloseRow(onClose: () {
              Navigator.of(context, rootNavigator: true).pop(null);
            }),
            const SizedBox(height: AppSpacing.xl),
            switch (_state) {
              _LinkingState.inProgress => const _InProgressContent(),
              _LinkingState.failed => _StatusContent(
                  icon: AppIcons.error,
                  iconBgColor: const Color(0xFFF9EAEA),
                  iconColor: AppColors.error,
                  title: AppStrings.bankLinkingFailed,
                  subtitle: AppStrings.bankLinkingFailedDesc,
                  onRetry: _retry,
                ),
            },
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}

// ─── Close row ────────────────────────────────────────────────────────────────

class _SheetCloseRow extends StatelessWidget {
  final VoidCallback onClose;
  const _SheetCloseRow({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onClose,
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
    );
  }
}

// ─── In-progress content ─────────────────────────────────────────────────────

class _InProgressContent extends StatelessWidget {
  const _InProgressContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                  backgroundColor: context.borderColor,
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.bank,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          AppStrings.bankLinkingInProgress,
          style: AppTypography.headingSmall.copyWith(
            fontVariations: const [FontVariation('wght', 600)],
            color: context.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.bankLinkingInProgressDesc,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Failed content ───────────────────────────────────────────────────────────

class _StatusContent extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const _StatusContent({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 36, color: iconColor),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: AppTypography.headingSmall.copyWith(
            fontVariations: const [FontVariation('wght', 600)],
            color: context.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: AppStrings.retry,
          onTap: onRetry,
          height: 48,
        ),
      ],
    );
  }
}

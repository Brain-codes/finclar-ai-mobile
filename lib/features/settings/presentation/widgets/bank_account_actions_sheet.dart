import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../expenses/data/models/bank_model.dart';

Future<void> showBankAccountActionsSheet(
  BuildContext context, {
  required BankModel bank,
  required Future<void> Function() onSync,
  required Future<void> Function() onUnlink,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (_) => _BankAccountActionsSheet(
      bank: bank,
      onSync: onSync,
      onUnlink: onUnlink,
    ),
  );
}

class _BankAccountActionsSheet extends StatefulWidget {
  final BankModel bank;
  final Future<void> Function() onSync;
  final Future<void> Function() onUnlink;

  const _BankAccountActionsSheet({
    required this.bank,
    required this.onSync,
    required this.onUnlink,
  });

  @override
  State<_BankAccountActionsSheet> createState() =>
      _BankAccountActionsSheetState();
}

class _BankAccountActionsSheetState extends State<_BankAccountActionsSheet> {
  bool _syncing = false;
  bool _unlinking = false;

  Future<void> _sync() async {
    setState(() => _syncing = true);
    try {
      await widget.onSync();
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _unlink() async {
    setState(() => _unlinking = true);
    try {
      await widget.onUnlink();
    } finally {
      if (mounted) {
        setState(() => _unlinking = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.xl,
          AppSpacing.screenPadding,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(AppIcons.bank, size: 20, color: AppColors.categoryTransport),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bank.name,
                      style: AppTypography.labelLarge
                          .copyWith(color: context.textPrimary),
                    ),
                    Text(
                      widget.bank.maskedAccountNumber,
                      style: AppTypography.bodySmall
                          .copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Sync transactions',
              onTap: _syncing || _unlinking ? null : _sync,
              isLoading: _syncing,
              variant: AppButtonVariant.outline,
              icon: AppIcons.transfer,
              height: 48,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Disconnect account',
              onTap: _syncing || _unlinking ? null : _unlink,
              isLoading: _unlinking,
              variant: AppButtonVariant.danger,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/group_member_model.dart';

/// Confirms removing a group member and collects the required
/// `redistribution` choice. Resolves to null when cancelled.
Future<RedistributionChoice?> showRemoveMemberSheet(
  BuildContext context, {
  required String name,
  required double? amountLeft,
  required String symbol,
}) {
  return showModalBottomSheet<RedistributionChoice>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RemoveMemberSheet(
      name: name,
      amountLeft: amountLeft,
      symbol: symbol,
    ),
  );
}

class _RemoveMemberSheet extends StatefulWidget {
  final String name;
  final double? amountLeft;
  final String symbol;

  const _RemoveMemberSheet({
    required this.name,
    required this.amountLeft,
    required this.symbol,
  });

  @override
  State<_RemoveMemberSheet> createState() => _RemoveMemberSheetState();
}

class _RemoveMemberSheetState extends State<_RemoveMemberSheet> {
  RedistributionChoice _choice = RedistributionChoice.split;

  bool get _hasOutstanding => (widget.amountLeft ?? 0) > 0;

  String get _outstandingLabel => formatCurrency(
        widget.amountLeft ?? 0,
        widget.symbol,
        abbreviate: false,
        withCommas: true,
      );

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderStrong),
                ),
                child: Icon(AppIcons.close,
                    size: 14, color: context.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF9EAEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.delete, size: 28, color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Remove ${widget.name}?',
            textAlign: TextAlign.center,
            style: AppTypography.headingSmall.copyWith(
              color: context.textPrimary,
              fontFamily: AppFonts.display,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _hasOutstanding
                ? '$_outstandingLabel of their share is still unpaid. Who covers it?'
                : 'They have met their share, so nothing needs to be reassigned.',
            textAlign: TextAlign.center,
            style:
                AppTypography.bodyMedium.copyWith(color: context.textSecondary),
          ),
          if (_hasOutstanding) ...[
            const SizedBox(height: AppSpacing.lg),
            _ChoiceRow(
              label: 'Split it between everyone else',
              description: 'Each remaining member takes an equal extra share.',
              selected: _choice == RedistributionChoice.split,
              onTap: () =>
                  setState(() => _choice = RedistributionChoice.split),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ChoiceRow(
              label: 'I will cover it',
              description: 'The full amount is added to your own target.',
              selected: _choice == RedistributionChoice.self,
              onTap: () => setState(() => _choice = RedistributionChoice.self),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondary,
                          fontVariations: const [FontVariation('wght', 500)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(_choice),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'Remove',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontVariations: const [FontVariation('wght', 500)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceRow({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: selected ? context.primaryMuted : context.surfaceVariant,
          borderRadius: AppRadius.radiusCard,
          border: Border.all(
            color: selected ? AppColors.primary : context.borderColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : context.borderStrong,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(AppIcons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimary,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.bodySmall
                        .copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

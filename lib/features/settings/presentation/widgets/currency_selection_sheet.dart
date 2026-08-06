import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';

/// Picks the account's default currency. Returns the ISO 4217 code, or null
/// when dismissed — the caller persists it.
Future<String?> showCurrencySelectionSheet(
  BuildContext context, {
  String? selected,
}) {
  return showAppSheet<String>(
    context,
    title: 'Default currency',
    children: [_CurrencySelectionContent(selected: selected)],
  );
}

class _CurrencySelectionContent extends StatelessWidget {
  final String? selected;
  const _CurrencySelectionContent({this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in AppConfig.supportedCurrencies) ...[
          _CurrencyOption(
            code: c.code,
            name: c.name,
            symbol: AppConfig.symbolFor(c.code),
            selected: c.code == selected?.toUpperCase(),
            onTap: () => Navigator.of(context).pop(c.code),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final String code;
  final String name;
  final String symbol;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.code,
    required this.name,
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryMuted : context.surfaceVariant,
          borderRadius: AppRadius.radiusCard,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.transparent,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                symbol,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: selected ? AppColors.primary : context.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '$name ($code)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: selected ? AppColors.primary : context.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              selected ? AppIcons.radioChecked : AppIcons.radioUnchecked,
              size: 20,
              color: selected ? AppColors.primary : context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

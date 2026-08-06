import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/expense_model.dart';

String expenseVerificationLabel(ExpenseVerificationLevel level) =>
    level == ExpenseVerificationLevel.verified ? 'Verified' : 'Self-reported';

IconData _icon(ExpenseVerificationLevel level) =>
    level == ExpenseVerificationLevel.verified ? AppIcons.shield : AppIcons.edit;

Color _fg(BuildContext context, ExpenseVerificationLevel level) =>
    level == ExpenseVerificationLevel.verified
        ? context.successOn
        : context.warningOn;

Color _bg(BuildContext context, ExpenseVerificationLevel level) =>
    level == ExpenseVerificationLevel.verified
        ? context.successBg
        : context.warningBg;

/// Icon + label pill on a tinted background. Use where the row has room to
/// explain itself — e.g. the expense detail card.
class ExpenseVerificationBadge extends StatelessWidget {
  final ExpenseVerificationLevel level;

  const ExpenseVerificationBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final fg = _fg(context, level);
    final label = expenseVerificationLabel(level);

    return Semantics(
      label: 'Verification: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: _bg(context, level),
          borderRadius: AppRadius.radiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(level), size: 12, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: fg,
                fontSize: 12,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact icon + label for dense list rows — no background fill, so it sits
/// quietly beside the category without competing with it.
///
/// Deliberately not tappable: the meaning must be readable at a glance rather
/// than hidden behind a tooltip or press.
class ExpenseVerificationLabel extends StatelessWidget {
  final ExpenseVerificationLevel level;

  const ExpenseVerificationLabel({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final fg = _fg(context, level);
    final label = expenseVerificationLabel(level);

    return Semantics(
      label: 'Verification: $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(level), size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: fg,
              fontSize: 11,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
        ],
      ),
    );
  }
}

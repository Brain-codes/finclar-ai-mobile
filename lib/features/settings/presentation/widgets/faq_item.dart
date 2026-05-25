import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

class FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const FaqItem({super.key, required this.question, required this.answer});

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimary,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  _expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                  size: 16,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.base),
            child: Text(
              widget.answer,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                height: 1.6,
              ),
            ),
          ),
      ],
    );
  }
}

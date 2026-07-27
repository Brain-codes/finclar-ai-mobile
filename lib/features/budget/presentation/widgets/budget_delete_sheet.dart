import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_sheet.dart';

/// [onConfirm] runs while the sheet stays open showing a spinner. Return false
/// to keep the sheet open so the user can retry.
Future<bool?> showBudgetDeleteSheet(
  BuildContext context, {
  required Future<bool> Function() onConfirm,
}) {
  return showAppSheet<bool>(
    context,
    title: 'Delete budget?',
    children: [_DeleteContent(onConfirm: onConfirm)],
  );
}

class _DeleteContent extends StatefulWidget {
  final Future<bool> Function() onConfirm;
  const _DeleteContent({required this.onConfirm});

  @override
  State<_DeleteContent> createState() => _DeleteContentState();
}

class _DeleteContentState extends State<_DeleteContent> {
  bool _isDeleting = false;

  Future<void> _confirm() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);
    final ok = await widget.onConfirm();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF9EAEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Delete budget?',
          style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Your budget will be cleared. You can always add a budget',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isDeleting
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _isDeleting
                          ? context.textTertiary
                          : context.textSecondary,
                      fontSize: 14,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: _isDeleting ? null : _confirm,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isDeleting
                        ? AppColors.error.withValues(alpha: 0.6)
                        : AppColors.error,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  alignment: Alignment.center,
                  child: _isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CupertinoActivityIndicator(
                            radius: 8,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Delete',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.white,
                            fontSize: 14,
                            fontVariations: const [FontVariation('wght', 500)],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

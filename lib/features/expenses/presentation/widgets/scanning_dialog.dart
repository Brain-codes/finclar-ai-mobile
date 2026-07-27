import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';

// Figma barrier: #f4f4f2 at 64% opacity
const _barrierColor = Color(0xA3F4F4F2);

Future<T?> showScanningProgressDialog<T>(
  BuildContext context, {
  File? imageFile,
  required double progress,
  required VoidCallback onCancel,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: _barrierColor,
    builder: (ctx) => _ScanningProgressDialog(
      imageFile: imageFile,
      progress: progress,
      onCancel: onCancel,
    ),
  );
}

Future<T?> showScanningFailedDialog<T>(
  BuildContext context, {
  File? imageFile,
  required VoidCallback onRetry,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: _barrierColor,
    builder: (ctx) =>
        _ScanningFailedDialog(imageFile: imageFile, onRetry: onRetry),
  );
}

class _ScanningProgressDialog extends StatelessWidget {
  final File? imageFile;
  final double progress;
  final VoidCallback onCancel;

  const _ScanningProgressDialog({
    required this.imageFile,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.screen),
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.borderStrong),
                      ),
                      child: Icon(
                        AppIcons.close,
                        size: 14,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Receipt image
              _ReceiptThumbnail(imageFile: imageFile),
              const SizedBox(height: AppSpacing.xl),
              // Title
              Text(
                'Scanning receipt',
                textAlign: TextAlign.center,
                style: AppTypography.headingSmall.copyWith(
                  color: context.textPrimary,
                  fontVariations: const [FontVariation('wght', 600)],
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Progress row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$pct%',
                    style: AppTypography.bodyLarge.copyWith(
                      color: context.textTertiary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Processing',
                    style: AppTypography.bodyLarge.copyWith(
                      color: context.textTertiary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Cancel button
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  width: 125,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.surfaceMuted,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: AppTypography.buttonLabel.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanningFailedDialog extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onRetry;

  const _ScanningFailedDialog({required this.imageFile, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.screen),
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: context.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.borderStrong),
                      ),
                      child: Icon(
                        AppIcons.close,
                        size: 14,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Receipt image
              _ReceiptThumbnail(imageFile: imageFile),
              const SizedBox(height: AppSpacing.xl),
              // Title
              Text(
                'Scanning failed',
                textAlign: TextAlign.center,
                style: AppTypography.headingSmall.copyWith(
                  color: context.textPrimary,
                  fontVariations: const [FontVariation('wght', 600)],
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Subtitle
              Text(
                'We could not complete the scanning. Please try again',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.textTertiary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Retry button
              AppButton(label: 'Retry', onTap: onRetry),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptThumbnail extends StatelessWidget {
  final File? imageFile;

  const _ReceiptThumbnail({this.imageFile});

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: AppRadius.radiusCard,
        child: Image.file(imageFile!, width: 86, height: 95, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 86,
      height: 95,
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.radiusCard,
      ),
      child: Icon(AppIcons.file, size: 32, color: context.textTertiary),
    );
  }
}

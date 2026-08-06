import 'dart:io';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../icons/app_icons.dart';
import 'app_sheet.dart';

/// Tappable row that attaches a receipt image, used anywhere the backend
/// accepts an optional `receipt` alongside a request (expenses, savings).
///
/// Owns the source sheet and the picker; the parent only holds the [File].
class AppAttachReceiptField extends StatefulWidget {
  final File? file;
  final ValueChanged<File?> onChanged;
  final String label;
  final String attachedLabel;

  /// Shown under the row — e.g. why attaching proof is worth it.
  final String? helperText;

  const AppAttachReceiptField({
    super.key,
    required this.file,
    required this.onChanged,
    this.label = 'Attach receipt',
    this.attachedLabel = 'Receipt attached',
    this.helperText,
  });

  @override
  State<AppAttachReceiptField> createState() => _AppAttachReceiptFieldState();
}

class _AppAttachReceiptFieldState extends State<AppAttachReceiptField> {
  final _picker = ImagePicker();
  bool _isAttaching = false;

  Future<void> _attach() async {
    if (_isAttaching) return;
    final source = await showAppSheet<ImageSource>(
      context,
      title: 'Attach receipt',
      children: [
        _SourceTile(
          icon: AppIcons.camera,
          label: 'Take a photo',
          onTap: (ctx) => Navigator.of(ctx).pop(ImageSource.camera),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SourceTile(
          icon: AppIcons.image,
          label: 'Choose from library',
          onTap: (ctx) => Navigator.of(ctx).pop(ImageSource.gallery),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
    if (source == null || !mounted) return;

    setState(() => _isAttaching = true);
    try {
      // Downscaled before upload — full-resolution camera shots blow past the
      // server's multipart body limit (413).
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
      );
      if (!mounted) return;
      if (image != null) widget.onChanged(File(image.path));
    } finally {
      if (mounted) setState(() => _isAttaching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attached = widget.file != null && !_isAttaching;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _attach,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: context.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.inputBorder),
            ),
            child: Row(
              children: [
                if (_isAttaching)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CupertinoActivityIndicator(
                      radius: 8,
                      color: context.textTertiary,
                    ),
                  )
                else
                  Icon(
                    attached ? AppIcons.check : AppIcons.image,
                    size: 18,
                    color: attached ? context.successOn : context.textTertiary,
                  ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _isAttaching
                        ? 'Attaching receipt...'
                        : attached
                        ? widget.attachedLabel
                        : widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: attached
                          ? context.textPrimary
                          : context.inputPlaceholder,
                    ),
                  ),
                ),
                if (attached)
                  GestureDetector(
                    onTap: () => widget.onChanged(null),
                    child: Icon(
                      AppIcons.close,
                      size: 16,
                      color: context.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.helperText!,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function(BuildContext) onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.textPrimary),
            const SizedBox(width: AppSpacing.base),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

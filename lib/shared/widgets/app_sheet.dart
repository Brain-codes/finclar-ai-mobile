import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../icons/app_icons.dart';

// Single source of truth for all modal bottom sheets.
// Handles: background color, rounded corners, padding, header (title + close).
// Pass content as [children]. Add [avoidKeyboard: true] for sheets with text fields.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required List<Widget> children,
  bool avoidKeyboard = false,
  // Fraction of screen height, e.g. 0.7 = 70%. Null = wrap content.
  double? heightFactor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (ctx) => AppSheet(
      title: title,
      avoidKeyboard: avoidKeyboard,
      heightFactor: heightFactor,
      children: children,
    ),
  );
}

class AppSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool avoidKeyboard;
  final double? heightFactor;

  const AppSheet({
    super.key,
    required this.title,
    required this.children,
    this.avoidKeyboard = false,
    this.heightFactor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = avoidKeyboard
        ? MediaQuery.of(context).viewInsets.bottom
        : 0.0;

    final header = _AppSheetHeader(
      title: title,
      onClose: () => Navigator.of(context).pop(),
    );

    final basePadding = EdgeInsets.fromLTRB(
      AppSpacing.screenPadding,
      AppSpacing.xl,
      AppSpacing.screenPadding,
      AppSpacing.xxxl + keyboardHeight,
    );

    if (heightFactor != null) {
      return SizedBox(
        height: screenHeight * heightFactor!,
        child: Padding(
          padding: basePadding,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: basePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: AppSpacing.xl),
          ...children,
        ],
      ),
    );
  }
}

class _AppSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _AppSheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: context.textPrimary,
            fontFamily: AppFonts.display,
          ),
        ),
        GestureDetector(
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
      ],
    );
  }
}

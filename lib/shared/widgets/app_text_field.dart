import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/extensions/context_extensions.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final Widget? prefix;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final int? maxLength;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffix,
    this.prefix,
    this.errorText,
    this.onChanged,
    this.textInputAction,
    this.onEditingComplete,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Input
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          keyboardAppearance: context.isDark ? Brightness.dark : Brightness.light,
          obscureText: obscureText,
          onChanged: onChanged,
          textInputAction: textInputAction,
          onEditingComplete: onEditingComplete,
          enabled: enabled,
          autofocus: autofocus,
          maxLength: maxLength,
          maxLines: maxLines,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: context.inputPlaceholder,
            ),
            filled: true,
            fillColor: enabled ? context.inputFill : context.surfaceVariant,
            prefixIcon: prefix,
            suffixIcon: suffix,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusInput,
              borderSide: BorderSide(
                color: hasError ? AppColors.error : context.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusInput,
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusInput,
              borderSide: BorderSide(color: context.borderColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusInput,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusInput,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),

        // Error text
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTypography.errorText,
          ),
        ],
      ],
    );
  }
}

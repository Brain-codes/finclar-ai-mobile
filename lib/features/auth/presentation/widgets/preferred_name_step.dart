import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// First phase of onboarding: asks what the user wants to be called.
///
/// Optional by design — the backend falls back to `username` for
/// `display_name`, so skipping costs nothing and keeps signup friction low.
class PreferredNameStep extends StatefulWidget {
  final bool isLoading;
  final ValueChanged<String> onContinue;
  final VoidCallback onSkip;

  const PreferredNameStep({
    super.key,
    required this.isLoading,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<PreferredNameStep> createState() => _PreferredNameStepState();
}

class _PreferredNameStepState extends State<PreferredNameStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _value => _controller.text.trim();

  void _submit() {
    if (_value.isEmpty || widget.isLoading) return;
    widget.onContinue(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                AppScreenHeader(
                  title: AppStrings.preferredNameTitle,
                  subtitle: AppStrings.preferredNameSubtitle,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: AppStrings.preferredNameLabel,
                  hint: AppStrings.preferredNameHint,
                  controller: _controller,
                  // Backend caps preferred_name at 50; enforce at input so an
                  // over-length value can never be submitted.
                  maxLength: 50,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _submit,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            0,
            AppSpacing.screenPadding,
            AppSpacing.base,
          ),
          child: Column(
            children: [
              // Rebuilds the CTA as the field fills so it enables/disables live.
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => AppButton(
                  label: AppStrings.continueText,
                  onTap: (_value.isEmpty || widget.isLoading) ? null : _submit,
                  isLoading: widget.isLoading,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              AppButton(
                label: AppStrings.skipForNow,
                onTap: widget.isLoading ? null : widget.onSkip,
                variant: AppButtonVariant.ghost,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

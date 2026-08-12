import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../providers/clara_audio_provider.dart';

Future<void> showClaraSettingsSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    title: 'Clara settings',
    avoidKeyboard: true,
    children: const [_ClaraSettingsContent()],
  );
}

class _ClaraSettingsContent extends ConsumerStatefulWidget {
  const _ClaraSettingsContent();

  @override
  ConsumerState<_ClaraSettingsContent> createState() =>
      _ClaraSettingsContentState();
}

class _ClaraSettingsContentState extends ConsumerState<_ClaraSettingsContent> {
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.preferredName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _nameChanged {
    final user = ref.read(userProfileProvider).valueOrNull;
    return _nameController.text.trim() != (user?.preferredName ?? '');
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    setState(() => _saving = true);
    try {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(preferredName: name);
      if (mounted) AppSnackbar.success(context, 'Details updated');
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioEnabled = ref.watch(claraAudioEnabledProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ToggleRow(
          icon: audioEnabled ? AppIcons.volumeUp : AppIcons.volumeMute,
          label: 'Reply sound',
          subtitle: "Play a tone when Clara responds",
          value: audioEnabled,
          onChanged: (v) =>
              ref.read(claraAudioEnabledProvider.notifier).setEnabled(v),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: AppStrings.preferredNameLabel,
          hint: AppStrings.preferredNameHint,
          controller: _nameController,
          maxLength: 50,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "This is the name Clara will call you by.",
          style: AppTypography.labelSmall.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Save changes',
          isLoading: _saving,
          onTap: _nameChanged && !_saving ? _save : null,
          height: 48,
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: context.textPrimary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.labelSmall
                    .copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.toggleActive,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: context.surfaceMuted,
          ),
        ),
      ],
    );
  }
}

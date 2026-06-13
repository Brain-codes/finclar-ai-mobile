import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_state_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../features/auth/providers/auth_repository_provider.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';

Future<void> showPasscodeChangedSheet(BuildContext context) {
  return showAppSheet(
    context,
    title: 'Passcode changed',
    isDismissible: false,
    enableDrag: false,
    showClose: false,
    children: [const _PasscodeChangedContent()],
  );
}

class _PasscodeChangedContent extends ConsumerStatefulWidget {
  const _PasscodeChangedContent();

  @override
  ConsumerState<_PasscodeChangedContent> createState() =>
      _PasscodeChangedContentState();
}

class _PasscodeChangedContentState
    extends ConsumerState<_PasscodeChangedContent> {
  bool _logoutAllDevices = false;
  bool _isLoading = false;

  Future<void> _onContinue() async {
    setState(() => _isLoading = true);
    try {
      if (_logoutAllDevices) {
        await ref.read(authRepositoryProvider).logoutAll();
      }
    } catch (e) {
      Log.e('Logout all failed — clearing session anyway', error: e);
    }
    await authStateService.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(AppIcons.success, color: AppColors.success, size: 28),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Your passcode has been updated successfully. You\'ll need to log in again to continue.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        GestureDetector(
          onTap: _isLoading
              ? null
              : () => setState(() => _logoutAllDevices = !_logoutAllDevices),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _logoutAllDevices ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: _logoutAllDevices ? AppColors.primary : context.borderColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _logoutAllDevices
                    ? const Icon(AppIcons.check, color: AppColors.white, size: 13)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Log out from all devices',
                style: AppTypography.bodyMedium.copyWith(color: context.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Login again',
          onTap: _isLoading ? null : _onContinue,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}

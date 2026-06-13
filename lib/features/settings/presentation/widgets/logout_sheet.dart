import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_state_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../features/auth/providers/auth_repository_provider.dart';
import '../../../../features/auth/providers/user_profile_provider.dart';
import '../../../../shared/icons/app_icons.dart';

Future<void> showLogoutSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (_) => const _LogoutSheetContent(),
  );
}

class _LogoutSheetContent extends ConsumerStatefulWidget {
  const _LogoutSheetContent();

  @override
  ConsumerState<_LogoutSheetContent> createState() => _LogoutSheetContentState();
}

class _LogoutSheetContentState extends ConsumerState<_LogoutSheetContent> {
  bool _isLoading = false;

  Future<void> _logout({required bool allDevices}) async {
    setState(() => _isLoading = true);
    try {
      if (allDevices) {
        await ref.read(authRepositoryProvider).logoutAll();
      } else {
        await ref.read(authRepositoryProvider).logout();
      }
    } catch (e) {
      Log.e('Logout API call failed — clearing session anyway', error: e);
    }
    // Always clear local session even if API call fails.
    ref.read(userProfileProvider.notifier).clear();
    await authStateService.logOut();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.xl,
          AppSpacing.screenPadding,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(AppIcons.close, size: 16, color: context.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Log out',
              style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Are you sure you want to log out?',
              style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'Cancel',
                    bg: context.surfaceVariant,
                    textColor: context.textSecondary,
                    onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SheetButton(
                    label: 'Log out',
                    bg: AppColors.error,
                    textColor: AppColors.white,
                    isLoading: _isLoading,
                    onTap: _isLoading ? null : () => _logout(allDevices: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _isLoading ? null : () => _logout(allDevices: true),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  'Log out from all devices',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const _SheetButton({
    required this.label,
    required this.bg,
    required this.textColor,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: bg, borderRadius: AppRadius.radiusFull),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(
                label,
                style: AppTypography.labelMedium.copyWith(color: textColor, fontSize: 15),
              ),
      ),
    );
  }
}

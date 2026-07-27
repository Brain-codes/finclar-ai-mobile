import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/providers/theme_provider.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../widgets/edit_username_sheet.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../widgets/logout_sheet.dart';
import '../widgets/theme_selection_sheet.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_profile_header.dart';
import '../widgets/settings_row.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../../subscription/presentation/widgets/active_subscription_sheet.dart';
import '../../../subscription/providers/subscription_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final available = await BiometricService.isAvailable();
    final enrolled =
        available && await BiometricService.hasEnrolledBiometrics();
    final enabled = await BiometricService.isEnabled();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available && enrolled;
      _biometricEnabled = enabled;
    });
  }

  Future<void> _onBiometricToggle(bool value) async {
    if (!value) {
      await BiometricService.setEnabled(false);
      await StorageService.clearBiometricPasscode();
      if (mounted) setState(() => _biometricEnabled = false);
      return;
    }

    final result = await BiometricService.authenticate(
      reason: 'Confirm your identity to enable biometric login',
    );
    if (!mounted) return;

    if (result == BiometricResult.success) {
      await BiometricService.setEnabled(true);
      if (mounted) setState(() => _biometricEnabled = true);
    } else if (result == BiometricResult.notEnrolled) {
      AppSnackbar.error(context, 'No biometrics enrolled on this device');
    } else if (result == BiometricResult.lockedOut) {
      AppSnackbar.error(
        context,
        'Biometrics locked. Use your passcode, then try again',
      );
    } else if (result != BiometricResult.cancelled) {
      AppSnackbar.error(context, 'Could not verify biometrics');
    }
  }

  Future<void> _onEditUsername(String current) async {
    final result = await showEditUsernameSheet(context, current: current);
    if (result != null && mounted) setState(() {});
  }

  Future<void> _onLogout() async {
    await showLogoutSheet(context);
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
        ThemeMode.system => 'System',
      };

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).valueOrNull;
    final email = user?.email ?? '';
    final username = user?.username ?? '';
    final themeMode = ref.watch(themeProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(title: 'Settings', onBack: () => context.pop(), circleBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.base,
                ),
                child: Column(
                  children: [
                    Center(
                      child: SettingsProfileHeader(
                        email: email,
                        username: username,
                        onEditTap: () => _onEditUsername(username),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SettingsCard(
                      children: [
                        SettingsRow(
                          icon: AppIcons.crown,
                          iconBg: AppColors.settingsRed,
                          label: 'Subscription',
                          trailing: SettingsRowTrailing.badge,
                          badgeLabel: isSubscribed ? 'Clara +' : 'Free',
                          onTap: () => isSubscribed
                              ? showActiveSubscriptionSheet(context)
                              : context.push(RouteNames.subscription),
                        ),
                        SettingsRow(
                          icon: AppIcons.lock,
                          iconBg: AppColors.primary,
                          label: 'Change passcode',
                          onTap: () =>
                              context.push(RouteNames.settingsChangePasscode),
                        ),
                        if (_biometricAvailable)
                          SettingsRow(
                            icon: AppIcons.fingerprint,
                            iconBg: AppColors.categoryHealth,
                            label: 'Biometric login',
                            trailing: SettingsRowTrailing.toggle,
                            toggleValue: _biometricEnabled,
                            onToggleChanged: _onBiometricToggle,
                          ),
                        SettingsRow(
                          icon: AppIcons.theme,
                          iconBg: AppColors.settingsNavy,
                          label: 'Appearance',
                          trailing: SettingsRowTrailing.value,
                          valueLabel: _themeLabel(themeMode),
                          onTap: () => showThemeSelectionSheet(context),
                        ),
                        SettingsRow(
                          icon: AppIcons.notification,
                          iconBg: AppColors.categoryShopping,
                          label: 'Notification',
                          trailing: SettingsRowTrailing.toggle,
                          toggleValue: _notificationsEnabled,
                          onToggleChanged: (v) =>
                              setState(() => _notificationsEnabled = v),
                        ),
                        SettingsRow(
                          icon: AppIcons.passport,
                          iconBg: AppColors.settingsCoral,
                          label: 'Money passport',
                          onTap: () {},
                        ),
                        SettingsRow(
                          icon: AppIcons.medal,
                          iconBg: AppColors.settingsBrown,
                          label: 'My badges',
                          onTap: () => context.push(RouteNames.badges),
                        ),
                        SettingsRow(
                          icon: AppIcons.game,
                          iconBg: AppColors.categoryPurple,
                          label: 'Gamify',
                          onTap: () => context.push(RouteNames.gamificationPreview),
                        ),
                        SettingsRow(
                          icon: AppIcons.bank,
                          iconBg: AppColors.categoryTransport,
                          label: 'My accounts',
                          onTap: () =>
                              context.push(RouteNames.settingsMyAccounts),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    SettingsCard(
                      children: [
                        SettingsRow(
                          icon: AppIcons.headphone,
                          iconBg: AppColors.warning,
                          label: 'Contact us',
                          onTap: () =>
                              context.push(RouteNames.settingsContactUs),
                        ),
                        SettingsRow(
                          icon: AppIcons.question,
                          iconBg: AppColors.categoryTransport,
                          label: "FAQ's",
                          onTap: () => context.push(RouteNames.settingsFaq),
                        ),
                        SettingsRow(
                          icon: AppIcons.star,
                          iconBg: AppColors.settingsRed,
                          label: 'Rate Finclar AI',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    SettingsCard(
                      children: [
                        SettingsRow(
                          icon: AppIcons.file,
                          iconBg: AppColors.settingsNavy,
                          label: 'Terms of Use',
                          onTap: () => context.push(RouteNames.termsOfService),
                        ),
                        SettingsRow(
                          icon: AppIcons.shield,
                          iconBg: AppColors.settingsAmber,
                          label: 'Privacy policy',
                          onTap: () => context.push(RouteNames.privacyPolicy),
                        ),
                        SettingsRow(
                          icon: AppIcons.logout,
                          iconBg: AppColors.settingsRed,
                          label: 'Log out',
                          onTap: _onLogout,
                        ),
                        SettingsRow(
                          icon: AppIcons.delete,
                          iconBg: AppColors.settingsRed,
                          label: 'Delete account',
                          onTap: () =>
                              context.push(RouteNames.settingsAccountDeletion),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


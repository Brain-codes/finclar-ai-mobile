import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../widgets/edit_username_sheet.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../widgets/logout_sheet.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_profile_header.dart';
import '../widgets/settings_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _username = 'estizzy';
  final String _email = 'chinasa.it@gmail.com';

  Future<void> _onEditUsername() async {
    final result = await showEditUsernameSheet(context, current: _username);
    if (result != null && mounted) setState(() => _username = result);
  }

  Future<void> _onLogout() async {
    await showLogoutSheet(context);
  }

  @override
  Widget build(BuildContext context) {
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
                        email: _email,
                        username: _username,
                        onEditTap: _onEditUsername,
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
                          badgeLabel: 'Free',
                          onTap: () => context.push(RouteNames.subscription),
                        ),
                        SettingsRow(
                          icon: AppIcons.lock,
                          iconBg: AppColors.primary,
                          label: 'Change passcode',
                          onTap: () =>
                              context.push(RouteNames.settingsChangePasscode),
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
                          onTap: () {},
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


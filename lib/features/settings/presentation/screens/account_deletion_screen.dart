import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../widgets/delete_confirmation_sheet.dart';
import '../widgets/settings_profile_header.dart';

class AccountDeletionScreen extends StatelessWidget {
  const AccountDeletionScreen({super.key});

  Future<void> _onDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmationSheet(context);
    if (confirmed == true && context.mounted) {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'Delete my account', onBack: () => context.pop(), circleBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.base,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: AppRadius.radiusSheet,
                        border: Border.all(color: context.borderColor),
                      ),
                      child: const SettingsProfileHeader(
                        email: 'chinasa.it@gmail.com',
                        username: 'estizzy',
                        layout: SettingsProfileLayout.horizontal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: AppRadius.radiusSheet,
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Before you go',
                            style: AppTypography.labelLarge.copyWith(
                              color: context.textQuaternary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.bodyMedium.copyWith(
                                color: context.textSecondary,
                                height: 1.6,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'Deleting your account means losing permanent access to Finclar and all your data. This cannot be undone.\n\nIt\'s sad to see you go. If something prompted this, our support team is here to help. Reach out to us at ',
                                ),
                                TextSpan(
                                  text: 'support@finclar.com',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: context.textPrimary,
                                    height: 1.6,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launchUrl(
                                          Uri.parse(
                                            'mailto:support@finclar.com',
                                          ),
                                        ),
                                ),
                                const TextSpan(text: ' or on '),
                                TextSpan(
                                  text: 'WhatsApp',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: context.textPrimary,
                                    height: 1.6,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launchUrl(
                                          Uri.parse(
                                            'https://wa.me/2348000000000',
                                          ),
                                          mode: LaunchMode.externalApplication,
                                        ),
                                ),
                                const TextSpan(
                                  text:
                                      '.\n\nReady to proceed? This action takes effect immediately.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: 'Delete my account',
                onTap: () => _onDelete(context),
                height: 48,
                variant: AppButtonVariant.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


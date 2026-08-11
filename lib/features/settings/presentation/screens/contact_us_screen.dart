import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../widgets/contact_option_tile.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'Contact us', onBack: () => context.pop(), circleBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HelpCard(),
                    const SizedBox(height: AppSpacing.base),
                    _ContactOptionsCard(
                      onClara: () => context.push(RouteNames.clara),
                      onEmail: () => _launch(
                        context,
                        Uri(
                          scheme: 'mailto',
                          path: AppConstants.supportEmail,
                        ),
                      ),
                      onWhatsapp: () => _launch(
                        context,
                        Uri.parse(AppConstants.supportWhatsappUrl),
                      ),
                      onWebsite: () => _launch(
                        context,
                        Uri.parse(AppConstants.websiteUrl),
                      ),
                      onMessage: () => context.push(RouteNames.settingsMessage),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _FindUsOnlineCard(
                      onInstagram: () => _launch(
                        context,
                        Uri.parse(AppConstants.instagramUrl),
                      ),
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

  Future<void> _launch(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      AppSnackbar.error(context, "Couldn't open ${uri.toString()}");
    }
  }
}


class _HelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Gradient-bordered avatar
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              // gradient: AppColors.claraBorderGradient,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2.5),
            child: ClipOval(
              child: Image.asset(
                'assets/images/clara-avatar.png',
                alignment: Alignment.topCenter,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Need help?',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textQuaternary,
              fontSize: 16,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Our team is always available to assist you',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactOptionsCard extends StatelessWidget {
  final VoidCallback onClara;
  final VoidCallback onEmail;
  final VoidCallback onWhatsapp;
  final VoidCallback onWebsite;
  final VoidCallback onMessage;
  const _ContactOptionsCard({
    required this.onClara,
    required this.onEmail,
    required this.onWhatsapp,
    required this.onWebsite,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Column(
        children: [
          ContactOptionTile(
            icon: AppIcons.aiFill,
            iconBg: AppColors.primary,
            title: 'Chat with Clara',
            subtitle: 'Get instant help from our AI assistant',
            onTap: onClara,
          ),
          Divider(height: 1, thickness: 1, color: context.borderColor),
          ContactOptionTile(
            icon: AppIcons.email,
            iconBg: AppColors.categoryTransport,
            title: 'Email',
            subtitle: AppConstants.supportEmail,
            onTap: onEmail,
          ),
          Divider(height: 1, thickness: 1, color: context.borderColor),
          ContactOptionTile(
            icon: AppIcons.whatsapp,
            iconBg: AppColors.success,
            title: 'Whatsapp',
            subtitle: AppConstants.supportWhatsappNumber,
            onTap: onWhatsapp,
          ),
          Divider(height: 1, thickness: 1, color: context.borderColor),
          ContactOptionTile(
            icon: AppIcons.link,
            iconBg: AppColors.categoryShopping,
            title: 'Website',
            subtitle: 'finclarai.com',
            onTap: onWebsite,
          ),
          Divider(height: 1, thickness: 1, color: context.borderColor),
          ContactOptionTile(
            icon: AppIcons.chat,
            iconBg: AppColors.settingsNavy,
            title: 'Message',
            subtitle: "We'll respond within 24 hours",
            onTap: onMessage,
          ),
        ],
      ),
    );
  }
}

class _FindUsOnlineCard extends StatelessWidget {
  final VoidCallback onInstagram;
  const _FindUsOnlineCard({required this.onInstagram});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'FIND US ONLINE',
            style: AppTypography.labelXSmall.copyWith(
              color: context.textTertiary,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: AppIcons.instagram,
                bg: const Color.fromARGB(0, 229, 89, 89),
                onTap: onInstagram,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;
  const _SocialIcon({required this.icon, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: context.textPrimary),
      ),
    );
  }
}

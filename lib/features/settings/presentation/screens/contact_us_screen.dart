import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../widgets/contact_option_tile.dart';
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
                      onMessage: () => context.push(RouteNames.settingsMessage),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _FindUsOnlineCard(),
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
  final VoidCallback onMessage;
  const _ContactOptionsCard({required this.onMessage});

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
            onTap: () {},
          ),
          Divider(height: 1, thickness: 1, color: context.borderColor),
          ContactOptionTile(
            icon: AppIcons.email,
            iconBg: AppColors.categoryTransport,
            title: 'Email',
            subtitle: "We'll respond within 24 hours",
            onTap: () {},
          ),
          Divider(height: 1, thickness: 1, color: context.borderColor),
          ContactOptionTile(
            icon: AppIcons.whatsapp,
            iconBg: AppColors.success,
            title: 'Whatsapp',
            subtitle: 'Get help from our team on Whatsapp',
            onTap: () {},
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
                icon: AppIcons.youtube,
                bg: const Color.fromARGB(0, 255, 0, 0),
              ),
              const SizedBox(width: AppSpacing.xl),
              _SocialIcon(
                icon: AppIcons.instagram,
                bg: const Color.fromARGB(0, 229, 89, 89),
              ),
              const SizedBox(width: AppSpacing.xl),
              _SocialIcon(
                icon: AppIcons.twitter,
                bg: const Color.fromARGB(0, 0, 0, 0),
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
  const _SocialIcon({required this.icon, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: context.textPrimary),
    );
  }
}

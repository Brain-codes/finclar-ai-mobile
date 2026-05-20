import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_top_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(onBack: () => Navigator.of(context).pop(), showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy Policy', style: AppTypography.headingLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Last updated: May 2026',
                      style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Your privacy matters to us. This policy explains how Finclar collects, uses, and protects your information.',
                      style: AppTypography.bodyMedium.copyWith(color: context.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Section(
                      title: '1. Information We Collect',
                      body:
                          'We collect information you provide directly (name, email, phone number), financial data you enter or connect, and usage data to improve the service.',
                    ),
                    _Section(
                      title: '2. How We Use Your Information',
                      body:
                          'We use your information to provide and improve Finclar, personalise your experience, send you notifications, and comply with legal obligations.',
                    ),
                    _Section(
                      title: '3. Data Sharing',
                      body:
                          'We do not sell your personal data. We may share data with trusted service providers who assist us in operating Finclar, subject to strict confidentiality agreements.',
                    ),
                    _Section(
                      title: '4. Data Security',
                      body:
                          'We use industry-standard encryption and security practices to protect your data. However, no method of transmission over the internet is 100% secure.',
                    ),
                    _Section(
                      title: '5. Your Rights',
                      body:
                          'You have the right to access, correct, or delete your personal data at any time. Contact us at privacy@finclar.com to exercise these rights.',
                    ),
                    _Section(
                      title: '6. Cookies & Analytics',
                      body:
                          'We use analytics tools to understand how users interact with the app. No personally identifiable information is shared with analytics providers.',
                    ),
                    _Section(
                      title: '7. Changes to This Policy',
                      body:
                          'We may update this policy periodically. We will notify you of significant changes via email or in-app notification.',
                    ),
                    _Section(
                      title: '8. Contact',
                      body: 'For privacy-related questions, contact us at privacy@finclar.com.',
                    ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppTypography.bodyMedium.copyWith(color: context.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}

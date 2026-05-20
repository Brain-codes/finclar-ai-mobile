import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_top_bar.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                    Text('Terms of Service', style: AppTypography.headingLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Last updated: May 2026',
                      style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'By using Finclar, you agree to these terms. Please read them carefully.',
                      style: AppTypography.bodyMedium.copyWith(color: context.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Section(
                      title: '1. Use of Service',
                      body:
                          'Finclar is a personal finance management platform. You must be at least 18 years old to use this service. You are responsible for maintaining the confidentiality of your account credentials.',
                    ),
                    _Section(
                      title: '2. Account Responsibilities',
                      body:
                          'You are responsible for all activity that occurs under your account. Notify us immediately of any unauthorized access. We are not liable for losses caused by unauthorized use of your account.',
                    ),
                    _Section(
                      title: '3. Prohibited Activities',
                      body:
                          'You may not use Finclar for any illegal purpose, to transmit harmful content, or to interfere with the service. Violation may result in immediate account termination.',
                    ),
                    _Section(
                      title: '4. Intellectual Property',
                      body:
                          'All content, trademarks, and intellectual property on Finclar belong to Finclar Inc. You may not reproduce or distribute any part of the service without written permission.',
                    ),
                    _Section(
                      title: '5. Limitation of Liability',
                      body:
                          'Finclar is provided "as is". We do not guarantee uninterrupted service and are not liable for any indirect, incidental, or consequential damages arising from your use of the platform.',
                    ),
                    _Section(
                      title: '6. Changes to Terms',
                      body:
                          'We may update these terms at any time. Continued use of the service after changes are posted constitutes acceptance of the new terms.',
                    ),
                    _Section(
                      title: '7. Contact',
                      body:
                          'For questions about these terms, contact us at legal@finclar.com.',
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

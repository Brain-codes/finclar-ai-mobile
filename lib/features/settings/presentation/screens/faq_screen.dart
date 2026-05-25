import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../widgets/faq_item.dart';
import '../../../../shared/widgets/app_top_bar.dart';

const _faqs = [
  (
    q: 'What is Finclar?',
    a: 'Finclar is a smart money management app that helps you track your income, spending and financial habits in one place, with insights that help you make better financial decisions.',
  ),
  (
    q: 'How does Finclar track my expenses?',
    a: 'Finclar allows you to track your finances in multiple ways:\n\n• Manual entry (type or scan receipts)\n• Bank account integration (coming soon)\n• SMS debit alerts (coming soon)',
  ),
  (
    q: 'Is my financial data secure?',
    a: 'Yes, your data is encrypted and protected using industry standard security measures. Finclar does not store your banking credentials.',
  ),
  (
    q: 'Do I need to connect my bank account?',
    a: 'No, you can use Finclar without connecting your bank account by manually adding transactions or using receipt tracking.',
  ),
  (
    q: 'Can I connect multiple bank accounts?',
    a: 'Yes, Finclar is designed to support multiple accounts so you can manage all your finances in one place.',
  ),
  (
    q: 'What is Money Passport?',
    a: 'Money Passport is a personalized financial summary that shows you how you spend, save and earn over time in a simple, visual and engaging format.',
  ),
  (
    q: 'Does Finclar give financial or investment advice?',
    a: 'Finclar provides personalized insights and guidance based on your financial habits to help you make better decisions.\n\nIn future updates, we may introduce partnerships with trusted financial platforms to offer users access to relevant financial opportunities.',
  ),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'FAQ', onBack: () => context.pop(), circleBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.base,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: AppRadius.radiusSheet,
                        border: Border.all(color: context.borderColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                      child: Column(
                        children: [
                          for (int i = 0; i < _faqs.length; i++) ...[
                            FaqItem(question: _faqs[i].q, answer: _faqs[i].a),
                            if (i < _faqs.length - 1)
                              Divider(height: 1, thickness: 1, color: context.borderColor),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Got more questions? ',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.settingsContactUs),
                          child: Text(
                            'Contact us',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontVariations: const [FontVariation('wght', 500)],
                            ),
                          ),
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


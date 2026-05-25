import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/account_tile.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../widgets/limit_exceeded_sheet.dart';


class MyAccountsScreen extends StatefulWidget {
  const MyAccountsScreen({super.key});

  @override
  State<MyAccountsScreen> createState() => _MyAccountsScreenState();
}

class _MyAccountsScreenState extends State<MyAccountsScreen> {
  // Use empty list to show empty state; use _mockAccounts for filled state
  final List<({String bank, String number})> _accounts = [];

  void _onLinkAccount() {
    if (_accounts.isNotEmpty) {
      showLimitExceededSheet(context);
    } else {
      // TODO: navigate to bank linking flow
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'My accounts', onBack: () => context.pop(), circleBack: true),
            Expanded(
              child: _accounts.isEmpty
                  ? _EmptyState()
                  : _FilledState(accounts: _accounts),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: 'Link an account',
                onTap: _onLinkAccount,
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.bank, size: 28, color: AppColors.categoryTransport),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'No linked accounts',
              style: AppTypography.labelLarge.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap below to add one, or as many as you need.',
              style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledState extends StatelessWidget {
  final List<({String bank, String number})> accounts;
  const _FilledState({required this.accounts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
          border: Border.all(color: context.borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: Column(
          children: [
            for (int i = 0; i < accounts.length; i++) ...[
              AccountTile(
                bankName: accounts[i].bank,
                accountNumber: accounts[i].number,
              ),
              if (i < accounts.length - 1)
                Divider(height: 1, thickness: 1, color: context.borderColor),
            ],
          ],
        ),
      ),
    );
  }
}


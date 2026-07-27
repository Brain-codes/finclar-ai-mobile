import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../expenses/data/models/bank_model.dart';
import '../../../expenses/providers/bank_providers.dart';
import '../widgets/account_tile.dart';
import '../widgets/bank_account_actions_sheet.dart';
import '../widgets/limit_exceeded_sheet.dart';

class MyAccountsScreen extends ConsumerWidget {
  const MyAccountsScreen({super.key});

  void _onLinkAccount(BuildContext context, List<BankModel> accounts) {
    if (accounts.isNotEmpty) {
      showLimitExceededSheet(context);
    } else {
      context.push(RouteNames.bankIntegration);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banksAsync = ref.watch(linkedBanksProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'My accounts',
              onBack: () => context.pop(),
              circleBack: true,
            ),
            Expanded(
              child: banksAsync.when(
                loading: () => _AccountsSkeleton(),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load accounts',
                    style: AppTypography.bodyMedium
                        .copyWith(color: context.textSecondary),
                  ),
                ),
                data: (accounts) => accounts.isEmpty
                    ? _EmptyState()
                    : _FilledState(accounts: accounts),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.base,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              child: banksAsync.when(
                loading: () => AppButton(label: 'Link an account', onTap: null, height: 48),
                error: (e, _) => AppButton(label: 'Link an account', onTap: null, height: 48),
                data: (accounts) => AppButton(
                  label: 'Link an account',
                  onTap: () => _onLinkAccount(context, accounts),
                  height: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _AccountsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
          border: Border.all(color: context.borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++) ...[
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    AppSkeleton.circle(size: 40),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton.text(width: 140, height: 13),
                        const SizedBox(height: 4),
                        AppSkeleton.text(width: 90, height: 11),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < 2)
                Divider(height: 1, thickness: 1, color: context.borderColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

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
              child: const Icon(AppIcons.bank, size: 28, color: AppColors.categoryTransport),
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

// ─── Filled state ─────────────────────────────────────────────────────────────

class _FilledState extends ConsumerWidget {
  final List<BankModel> accounts;
  const _FilledState({required this.accounts});

  Future<void> _onAccountTap(BuildContext context, WidgetRef ref, BankModel bank) async {
    await showBankAccountActionsSheet(
      context,
      bank: bank,
      onSync: () async {
        await ref.read(linkedBanksProvider.notifier).sync(bank.id);
        if (context.mounted) {
          AppSnackbar.success(context, 'Transactions synced from ${bank.name}');
        }
      },
      onUnlink: () async {
        await ref.read(linkedBanksProvider.notifier).unlink(bank.id);
        if (context.mounted) {
          AppSnackbar.success(context, '${bank.name} disconnected');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                bankName: accounts[i].name,
                accountNumber: accounts[i].maskedAccountNumber,
                onTap: () => _onAccountTap(context, ref, accounts[i]),
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

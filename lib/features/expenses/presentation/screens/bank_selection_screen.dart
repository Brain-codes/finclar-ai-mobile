import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/services/bank_connect_service.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../data/models/bank_model.dart';
import '../../providers/bank_providers.dart';
import '../widgets/bank_linking_sheet.dart';

class BankSelectionScreen extends ConsumerStatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  ConsumerState<BankSelectionScreen> createState() =>
      _BankSelectionScreenState();
}

class _BankSelectionScreenState extends ConsumerState<BankSelectionScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AvailableBankModel> _filtered(List<AvailableBankModel> banks) =>
      _query.isEmpty
          ? banks
          : banks
              .where(
                  (b) => b.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();

  Future<void> _onBankTap(AvailableBankModel bank) async {
    final user = ref.read(userProfileProvider).valueOrNull;
    if (user == null) {
      AppSnackbar.error(context, 'Please wait for your profile to load');
      return;
    }

    // Mono shows its own institution picker; tapping a bank here just opens
    // Mono Connect (institution ids differ from our backend NIP codes).
    final result = await BankConnectService.launch(
      context,
      customerName: user.username,
      customerEmail: user.email,
    );
    if (!mounted) return;
    switch (result.status) {
      case BankConnectStatus.notConfigured:
        AppSnackbar.error(context, 'Bank linking is not available right now');
        return;
      case BankConnectStatus.cancelled:
        return;
      case BankConnectStatus.success:
        break;
    }

    final linked = await showBankLinkingSheet(
      context,
      bankName: bank.name,
      onLink: () =>
          ref.read(linkedBanksProvider.notifier).link(result.code!),
    );
    if (linked != null && mounted) {
      Analytics.bankLinked(bankName: bank.name);
      context.push(RouteNames.bankLinkingSuccess, extra: linked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(availableBanksProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(
              onBack: () => context.pop(),
              stepLabel: AppStrings.step3of3,
              circleBack: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Text(
                AppStrings.selectBank,
                style: AppTypography.headingMedium.copyWith(
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: _SearchField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: banksAsync.when(
                loading: () => _BankListSkeleton(),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load banks',
                    style: AppTypography.bodyMedium
                        .copyWith(color: context.textSecondary),
                  ),
                ),
                data: (banks) {
                  final filtered = _filtered(banks);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No banks found',
                        style: AppTypography.bodyMedium
                            .copyWith(color: context.textSecondary),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _BankRow(
                      bank: filtered[index],
                      onTap: () => _onBankTap(filtered[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _BankListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      itemCount: 10,
      itemBuilder: (context, i) => SizedBox(
        height: 56,
        child: Row(
          children: [
            AppSkeleton.circle(size: 32),
            const SizedBox(width: AppSpacing.base),
            AppSkeleton.text(width: 160, height: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Search field ─────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.radiusInput,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.base),
          Icon(AppIcons.search, size: 16, color: context.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.labelMedium.copyWith(
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchForBankName,
                hintStyle: AppTypography.labelMedium.copyWith(
                  color: context.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
        ],
      ),
    );
  }
}

// ─── Bank row ─────────────────────────────────────────────────────────────────

class _BankRow extends StatelessWidget {
  final AvailableBankModel bank;
  final VoidCallback onTap;

  const _BankRow({required this.bank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor),
              ),
              child: Icon(
                AppIcons.bank,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            Text(
              bank.name,
              style: AppTypography.labelMedium.copyWith(
                color: context.textQuaternary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

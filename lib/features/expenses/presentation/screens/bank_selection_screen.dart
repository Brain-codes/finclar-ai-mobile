import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../widgets/bank_linking_sheet.dart';

class BankSelectionScreen extends StatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _banks = [
    'Union Bank',
    'United Bank for Africa',
    'Guarantee Trust Bank',
    'First Bank',
    'Access Bank',
    'Opay MFB',
    'VFD MFB',
    'FCMB',
    'Sterling Bank',
    'Providus Bank',
    'Lotus Bank',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered => _query.isEmpty
      ? _banks
      : _banks
          .where((b) => b.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  void _onBankTap(String bankName) {
    showBankLinkingSheet(
      context,
      bankName: bankName,
      onSuccess: () => context.push(RouteNames.bankLinkingSuccess, extra: bankName),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: _filtered.length,
                itemBuilder: (context, index) => _BankRow(
                  name: _filtered[index],
                  onTap: () => _onBankTap(_filtered[index]),
                ),
              ),
            ),
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
  final String name;
  final VoidCallback onTap;

  const _BankRow({required this.name, required this.onTap});

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
              name,
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

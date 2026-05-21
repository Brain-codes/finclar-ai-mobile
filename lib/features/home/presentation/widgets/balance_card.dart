import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class BalanceCard extends StatefulWidget {
  final String balance;

  const BalanceCard({super.key, this.balance = '₦1,850,000.00'});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isHidden = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      // width: double.infinity,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.radiusCardLarge,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xl,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.availableBalance,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _isHidden ? '₦ ••••••' : widget.balance,
                    style: AppTypography.amountLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            // GestureDetector(
            //   onTap: () => setState(() => _isHidden = !_isHidden),
            //   child: Container(
            //     width: 28,
            //     height: 28,
            //     decoration: const BoxDecoration(
            //       color: AppColors.primaryDark,
            //       shape: BoxShape.circle,
            //     ),
            //     child: Icon(
            //       _isHidden ? AppIcons.eyeOff : AppIcons.eyeOn,
            //       color: AppColors.white,
            //       size: 14,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

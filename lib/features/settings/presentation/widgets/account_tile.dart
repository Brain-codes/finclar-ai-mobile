import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

class AccountTile extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final VoidCallback? onTap;

  const AccountTile({
    super.key,
    required this.bankName,
    required this.accountNumber,
    this.onTap,
  });

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderStrong),
              ),
              child: Icon(AppIcons.bank, size: 20, color: AppColors.categoryTransport),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    accountNumber,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, size: 16, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}

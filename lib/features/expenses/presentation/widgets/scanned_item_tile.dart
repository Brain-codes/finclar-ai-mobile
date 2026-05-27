import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../data/models/scanned_receipt_model.dart';
import 'expense_category_utils.dart';

class ScannedItemTile extends StatelessWidget {
  final ScannedItemModel item;
  final VoidCallback onTap;

  const ScannedItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryColor = expenseCategoryColor(item.category);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      fontVariations: const [FontVariation('wght', 500)],
                      color: context.textQuaternary,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 12,
                      fontVariations: const [FontVariation('wght', 400)],
                      color: categoryColor,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(item.amount),
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontVariations: const [FontVariation('wght', 400)],
                    color: context.textQuaternary,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'x${item.quantity} / ${_formatAmount(item.unitPrice)}',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    fontVariations: const [FontVariation('wght', 400)],
                    color: context.textTertiary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value == value.truncateToDouble()) {
      return '₦${_addCommas(value.toInt().toString())}';
    }
    return '₦${_addCommas(value.toStringAsFixed(2))}';
  }

  String _addCommas(String s) {
    final parts = s.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    if (parts.length > 1) buffer.write('.${parts[1]}');
    return buffer.toString();
  }
}

class ScannedItemDivider extends StatelessWidget {
  const ScannedItemDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 16, thickness: 1, color: AppColors.border);
  }
}

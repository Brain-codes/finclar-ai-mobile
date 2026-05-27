import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/scanned_receipt_model.dart';
import '../widgets/delete_receipt_sheet.dart';
import '../widgets/edit_scanned_item_sheet.dart';
import '../widgets/scanned_item_tile.dart';

class ScannedExpenseScreen extends StatefulWidget {
  final ScannedReceiptModel receipt;

  const ScannedExpenseScreen({super.key, required this.receipt});

  @override
  State<ScannedExpenseScreen> createState() => _ScannedExpenseScreenState();
}

class _ScannedExpenseScreenState extends State<ScannedExpenseScreen> {
  late ScannedReceiptModel _receipt;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
  }

  double get _total => _receipt.items.fold(0, (sum, item) => sum + item.amount);

  Future<void> _onEditItem(ScannedItemModel item) async {
    final updated = await showEditScannedItemSheet(context, item: item);
    if (updated == null) return;

    final items = _receipt.items
        .map((i) => i.id == updated.id ? updated : i)
        .toList();
    setState(() {
      _receipt = _receipt.copyWith(
        items: items,
        totalAmount: items.fold<double>(0.0, (s, i) => s + i.amount),
      );
    });
  }

  Future<void> _onDelete() async {
    final confirmed = await showDeleteReceiptSheet(context);
    if (confirmed == true && mounted) context.pop();
  }

  void _onSave() {
    AppSnackbar.success(context, 'Expenses saved successfully');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ScannedTopBar(
              title: _receipt.merchantName,
              onBack: () => context.pop(),
              onDelete: _onDelete,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _SummaryCard(total: _total),
                    const SizedBox(height: AppSpacing.md),
                    _ItemsCard(receipt: _receipt, onEditItem: _onEditItem),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            _SaveBar(onSave: _onSave),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _ScannedTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onDelete;

  const _ScannedTopBar({
    required this.title,
    required this.onBack,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.back,
                size: 20,
                color: context.textQuaternary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge.copyWith(
                color: context.textPrimary,
                fontFamily: AppFonts.display,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor),
              ),
              child: Icon(
                AppIcons.delete,
                size: 20,
                color: context.textQuaternary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double total;
  const _SummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total expense',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontVariations: const [FontVariation('wght', 400)],
              color: context.textTertiary,
              height: 1.33,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatTotal(total),
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 24,
              fontVariations: const [FontVariation('wght', 500)],
              color: context.textQuaternary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _AiInsightRow(),
        ],
      ),
    );
  }

  String _formatTotal(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final buffer = StringBuffer('₦');
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    buffer.write('.${parts[1]}');
    return buffer.toString();
  }
}

class _AiInsightRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.claraGradient.createShader(bounds),
          child: const Icon(AppIcons.aiFill, size: 16, color: AppColors.white),
        ),
        const SizedBox(width: AppSpacing.xs),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.claraGradient.createShader(bounds),
          child: Text(
            'You spent 15% of your income.',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontVariations: const [FontVariation('wght', 500)],
              color: AppColors.white,
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Items card ───────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  final ScannedReceiptModel receipt;
  final ValueChanged<ScannedItemModel> onEditItem;

  const _ItemsCard({required this.receipt, required this.onEditItem});

  @override
  Widget build(BuildContext context) {
    final items = receipt.items;
    final File? imageFile = receipt.imagePath != null
        ? File(receipt.imagePath!)
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt header tile
          _ReceiptHeaderTile(imageFile: imageFile, itemCount: items.length),
          const SizedBox(height: AppSpacing.sm),
          // Item list
          ...List.generate(items.length * 2 - 1, (index) {
            if (index.isOdd) return const ScannedItemDivider();
            final item = items[index ~/ 2];
            return ScannedItemTile(item: item, onTap: () => onEditItem(item));
          }),
        ],
      ),
    );
  }
}

class _ReceiptHeaderTile extends StatelessWidget {
  final File? imageFile;
  final int itemCount;

  const _ReceiptHeaderTile({required this.imageFile, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.radiusCard,
      ),
      child: Row(
        children: [
          // Image thumbnail
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageFile != null
                ? Image.file(imageFile!, fit: BoxFit.cover)
                : Icon(AppIcons.file, size: 20, color: context.textTertiary),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment receipt',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontVariations: const [FontVariation('wght', 500)],
                  color: context.textQuaternary,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$itemCount items',
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
    );
  }
}

// ─── Save bar ─────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final VoidCallback onSave;
  const _SaveBar({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom,
      ),
      color: context.surfaceColor,
      child: AppButton(label: 'Save', onTap: onSave),
    );
  }
}

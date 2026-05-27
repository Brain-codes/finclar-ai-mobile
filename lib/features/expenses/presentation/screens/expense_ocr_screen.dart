import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/scanned_receipt_model.dart';

enum _OcrStatus { idle, scanning, failed }

class ExpenseOcrScreen extends StatefulWidget {
  const ExpenseOcrScreen({super.key});

  @override
  State<ExpenseOcrScreen> createState() => _ExpenseOcrScreenState();
}

class _ExpenseOcrScreenState extends State<ExpenseOcrScreen> {
  _OcrStatus _status = _OcrStatus.idle;
  File? _imageFile;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchCamera());
  }

  Future<void> _launchCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked == null) {
      if (mounted) context.pop();
      return;
    }

    if (!mounted) return;
    setState(() {
      _imageFile = File(picked.path);
      _status = _OcrStatus.scanning;
      _progress = 0.0;
    });

    _startFakeScanProgress();
  }

  // Simulates scan progress — replaced with real OCR later.
  void _startFakeScanProgress() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted || _status != _OcrStatus.scanning) return false;
      final next = (_progress + 0.015).clamp(0.0, 0.95);
      setState(() => _progress = next);
      return next < 0.95;
    }).then((_) {
      if (!mounted || _status != _OcrStatus.scanning) return;
      _onScanComplete();
    });
  }

  void _onScanComplete() {
    // Placeholder — real OCR response wired here later.
    final mockReceipt = ScannedReceiptModel(
      merchantName: 'Bokku Mart',
      totalAmount: 250000,
      imagePath: _imageFile?.path,
      items: [
        ScannedItemModel(
          id: '1',
          name: 'Indomie Instant Noodle 70g',
          category: 'Food',
          amount: 5000,
          quantity: 1,
          unitPrice: 5000,
        ),
        ScannedItemModel(
          id: '2',
          name: 'Bokku Egg Big Size 15g',
          category: 'Food',
          amount: 12000,
          quantity: 2,
          unitPrice: 6000,
        ),
        ScannedItemModel(
          id: '3',
          name: 'Bull Basmati Rice 12kg',
          category: 'Food',
          amount: 24000,
          quantity: 1,
          unitPrice: 24000,
        ),
        ScannedItemModel(
          id: '4',
          name: 'Golden Penny Spaghetti 12g',
          category: 'Food',
          amount: 24000,
          quantity: 2,
          unitPrice: 12000,
        ),
        ScannedItemModel(
          id: '5',
          name: 'Maltina 400ml',
          category: 'Food',
          amount: 20000,
          quantity: 4,
          unitPrice: 5000,
        ),
        ScannedItemModel(
          id: '6',
          name: 'Welch Orange Drink 60ml',
          category: 'Food',
          amount: 27000,
          quantity: 5,
          unitPrice: 5400,
        ),
        ScannedItemModel(
          id: '7',
          name: 'Fabuloso House Cleaning Liquid Soap 600ml',
          category: 'Utilities',
          amount: 27000,
          quantity: 1,
          unitPrice: 27000,
        ),
        ScannedItemModel(
          id: '8',
          name: 'Pinky Lush Toilet Tissue Paper 50g',
          category: 'Utilities',
          amount: 10000,
          quantity: 2,
          unitPrice: 5000,
        ),
        ScannedItemModel(
          id: '9',
          name: 'Zara Man White Tripple Knit Singlet 1kg',
          category: 'Shopping',
          amount: 15000,
          quantity: 3,
          unitPrice: 5000,
        ),
      ],
    );

    if (mounted) {
      context.pushReplacement(RouteNames.scannedExpense, extra: mockReceipt);
    }
  }

  void _onCancel() {
    setState(() => _status = _OcrStatus.idle);
    if (mounted) context.pop();
  }

  void _onRetry() {
    Navigator.of(context).pop();
    _launchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matches the Figma overlay colour (#f4f4f2)
      backgroundColor: AppColors.border,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _OcrStatus.scanning:
        return _InlineDialog(
          child: _ScanningProgressCard(
            imageFile: _imageFile,
            progress: _progress,
            onCancel: _onCancel,
            onClose: _onCancel,
          ),
        );
      case _OcrStatus.failed:
        return _InlineDialog(
          child: _ScanningFailedCard(
            imageFile: _imageFile,
            onRetry: _onRetry,
            onClose: _onCancel,
          ),
        );
      case _OcrStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

// ─── Inline dialog wrapper (centres the card on screen) ──────────────────────

class _InlineDialog extends StatelessWidget {
  final Widget child;
  const _InlineDialog({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: child,
      ),
    );
  }
}

// ─── Scanning progress card ───────────────────────────────────────────────────

class _ScanningProgressCard extends StatelessWidget {
  final File? imageFile;
  final double progress;
  final VoidCallback onCancel;
  final VoidCallback onClose;

  const _ScanningProgressCard({
    required this.imageFile,
    required this.progress,
    required this.onCancel,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CloseRow(onClose: onClose),
          const SizedBox(height: AppSpacing.md),
          _ReceiptThumb(imageFile: imageFile),
          const SizedBox(height: AppSpacing.xl),
          _DialogTitle(text: 'Scanning receipt'),
          const SizedBox(height: AppSpacing.sm),
          _ProgressRow(pct: pct),
          const SizedBox(height: AppSpacing.xl),
          _CancelButton(onCancel: onCancel),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Scanning failed card ─────────────────────────────────────────────────────

class _ScanningFailedCard extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ScanningFailedCard({
    required this.imageFile,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CloseRow(onClose: onClose),
          const SizedBox(height: AppSpacing.md),
          _ReceiptThumb(imageFile: imageFile),
          const SizedBox(height: AppSpacing.xl),
          _DialogTitle(text: 'Scanning failed'),
          const SizedBox(height: AppSpacing.sm),
          _FailedSubtitle(),
          const SizedBox(height: AppSpacing.xl),
          _RetryButton(onRetry: onRetry),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Small sub-widgets ────────────────────────────────────────────────────────

class _CloseRow extends StatelessWidget {
  final VoidCallback onClose;
  const _CloseRow({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Icon(
              Icons.close,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReceiptThumb extends StatelessWidget {
  final File? imageFile;
  const _ReceiptThumb({this.imageFile});

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(imageFile!, width: 86, height: 95, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 86,
      height: 95,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.receipt_long_outlined,
        size: 32,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  final String text;
  const _DialogTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'BricolageGrotesque',
        fontSize: 20,
        fontVariations: [FontVariation('wght', 600)],
        color: AppColors.textPrimary,
        height: 1.2,
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final int pct;
  const _ProgressRow({required this.pct});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$pct%',
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 16,
            fontVariations: [FontVariation('wght', 400)],
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Text(
          'Processing',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 16,
            fontVariations: [FontVariation('wght', 400)],
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FailedSubtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'We could not complete the scanning. Please try again',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Geist',
        fontSize: 16,
        fontVariations: [FontVariation('wght', 400)],
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onCancel;
  const _CancelButton({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCancel,
      child: Container(
        width: 125,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 16,
            fontVariations: [FontVariation('wght', 500)],
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onRetry;
  const _RetryButton({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        width: 113,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Retry',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 16,
            fontVariations: [FontVariation('wght', 500)],
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

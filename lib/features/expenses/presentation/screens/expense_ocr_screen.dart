import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/ai_config.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/receipt_ai_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/scanned_receipt_model.dart';
import '../../providers/expense_providers.dart';

enum _OcrStatus { idle, scanning, failed }

class ExpenseOcrScreen extends ConsumerStatefulWidget {
  const ExpenseOcrScreen({super.key});

  @override
  ConsumerState<ExpenseOcrScreen> createState() => _ExpenseOcrScreenState();
}

class _ExpenseOcrScreenState extends ConsumerState<ExpenseOcrScreen> {
  _OcrStatus _status = _OcrStatus.idle;
  File? _imageFile;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchCamera());
  }

  Future<void> _launchCamera() async {
    Log.i('[OCR Screen] Opening camera');
    final picker = ImagePicker();
    // Downscale + compress so the upload stays well under server limits
    // (full-res camera photos are several MB → HTTP 413). Also keeps the
    // OpenAI base64 payload small/cheap. A receipt stays legible at this size.
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 70,
    );

    if (picked == null) {
      Log.w('[OCR Screen] Camera dismissed — no image selected');
      if (mounted) context.pop();
      return;
    }

    Log.i('[OCR Screen] Image captured: ${picked.path}');
    if (!mounted) return;
    setState(() {
      _imageFile = File(picked.path);
      _status = _OcrStatus.scanning;
      _progress = 0.0;
    });

    _startProgressAnimation();
    _runOcr();
  }

  // Advances progress to 90% while OCR runs, then holds until OCR resolves.
  void _startProgressAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted || _status != _OcrStatus.scanning) return false;
      if (_progress >= 0.9) return true;
      setState(() => _progress = (_progress + 0.015).clamp(0.0, 0.9));
      return true;
    });
  }

  Future<void> _runOcr() async {
    try {
      if (AiConfig.receiptScanSource == ReceiptScanSource.backend) {
        await _scanViaBackend();
      } else {
        await _scanViaOpenAi();
      }
    } catch (e) {
      Log.e('[OCR Screen] Receipt scan failed — showing failed state', error: e);
      if (mounted) setState(() => _status = _OcrStatus.failed);
    }
  }

  // On-device OpenAI vision → review/edit items before saving.
  Future<void> _scanViaOpenAi() async {
    final receipt = await ReceiptAiService.scanReceipt(_imageFile!);
    if (!mounted || _status != _OcrStatus.scanning) return;
    Log.i('[OCR Screen] OpenAI scan succeeded — opening review screen');
    setState(() => _progress = 1.0);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      context.pushReplacement(RouteNames.scannedExpense, extra: receipt);
    }
  }

  // Backend /expenses/receipt → expense created server-side → show review screen.
  // The expense is already saved; the review screen's Save button just pops.
  Future<void> _scanViaBackend() async {
    final expense =
        await ref.read(expenseListProvider.notifier).scanReceipt(_imageFile!);
    if (!mounted || _status != _OcrStatus.scanning) return;
    Log.i('[OCR Screen] Backend scan succeeded — opening review screen');
    setState(() => _progress = 1.0);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      final receipt = ScannedReceiptModel.fromExpenseModel(
        expense,
        imagePath: _imageFile!.path,
      );
      context.pushReplacement(RouteNames.scannedExpense, extra: receipt);
    }
  }

  void _onCancel() {
    Log.d('[OCR Screen] Scan cancelled by user');
    setState(() => _status = _OcrStatus.idle);
    if (mounted) context.pop();
  }

  void _onRetry() {
    Log.d('[OCR Screen] Retry tapped — relaunching camera');
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

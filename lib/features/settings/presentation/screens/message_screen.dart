import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_top_bar.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _subjectController = TextEditingController();
  final _noteController = TextEditingController();
  final List<XFile> _images = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _subjectController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _subjectController.text.trim().isNotEmpty &&
      _noteController.text.trim().isNotEmpty;

  Future<void> _pickImage() async {
    if (_images.length >= 4) return;
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _images.add(file));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _onSubmit() {
    AppSnackbar.success(context, 'Message sent successfully');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(onBack: () => context.pop(), circleBack: true),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppScreenHeader(
                      title: 'Message',
                      subtitle: 'Kindly enter your questions or requests below',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: 'Subject',
                      hint: 'Enter subject',
                      controller: _subjectController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    AppTextField(
                      label: 'Note',
                      hint: 'Enter your message',
                      controller: _noteController,
                      maxLines: 5,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _ImagePickerCard(
                      images: _images,
                      onAdd: _pickImage,
                      onRemove: _removeImage,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppButton(
                      label: 'Submit',
                      onTap: _canSubmit ? _onSubmit : null,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const _ImagePickerCard({
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Add image',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '(${images.length}/4)',
                style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: List.generate(4, (i) {
              final isFilled = i < images.length;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? AppSpacing.sm : 0),
                  child: isFilled
                      ? _FilledSlot(image: images[i], onRemove: () => onRemove(i))
                      : _EmptySlot(onTap: images.length < 4 ? onAdd : null),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final VoidCallback? onTap;
  const _EmptySlot({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: AppRadius.radiusCard,
          border: Border.all(color: context.borderColor),
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(AppIcons.add, size: 18, color: context.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;
  const _FilledSlot({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppRadius.radiusCard,
          child: Image.file(
            File(image.path),
            height: 76,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

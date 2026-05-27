import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_avatar.dart';

// ─── User bubbles ─────────────────────────────────────────────────────────────

class GroupChatUserBubble extends StatelessWidget {
  final String text;
  const GroupChatUserBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.surfaceMuted,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(3),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: context.textQuaternary,
            fontSize: 14,
            fontVariations: const [FontVariation('wght', 400)],
          ),
        ),
      ),
    );
  }
}

class GroupChatUserImageBubble extends StatelessWidget {
  final String imagePath;
  const GroupChatUserImageBubble({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _showImageModal(context, imagePath),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            imagePath,
            width: 109,
            height: 128,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// ─── Other bubbles ────────────────────────────────────────────────────────────

class GroupChatOtherBubble extends StatelessWidget {
  final String name;
  final String text;
  final bool showAvatar;
  final bool showName;

  const GroupChatOtherBubble({
    super.key,
    required this.name,
    required this.text,
    this.showAvatar = true,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAvatar)
          AppAvatar(initials: name, size: 24, shape: BoxShape.circle)
        else
          const SizedBox(width: 24),
        const SizedBox(width: AppSpacing.xs + 2),
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(showAvatar ? 3 : 16),
                topRight: const Radius.circular(24),
                bottomLeft: const Radius.circular(24),
                bottomRight: const Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showName) ...[
                  Text(
                    name,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 12,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  text,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white,
                    fontSize: 14,
                    fontVariations: const [FontVariation('wght', 400)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GroupChatOtherImageBubble extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool showAvatar;
  final bool showName;

  const GroupChatOtherImageBubble({
    super.key,
    required this.name,
    required this.imagePath,
    this.showAvatar = true,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    const avatarWidth = 24.0;
    const gap = AppSpacing.xs + 2.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName)
          Padding(
            padding: const EdgeInsets.only(
              left: avatarWidth + gap,
              bottom: 4,
            ),
            child: Text(
              name,
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondary,
                fontSize: 12,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showAvatar)
              AppAvatar(initials: name, size: avatarWidth, shape: BoxShape.circle)
            else
              const SizedBox(width: avatarWidth),
            const SizedBox(width: gap),
            GestureDetector(
              onTap: () => _showImageModal(context, imagePath),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  imagePath,
                  width: 109,
                  height: 128,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Date divider ─────────────────────────────────────────────────────────────

class GroupChatDateDivider extends StatelessWidget {
  final String label;
  const GroupChatDateDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: context.textSecondary,
          fontSize: 12,
          fontVariations: const [FontVariation('wght', 400)],
        ),
      ),
    );
  }
}

// ─── Typing indicator ─────────────────────────────────────────────────────────

class GroupChatTypingBubble extends StatefulWidget {
  final String name;
  const GroupChatTypingBubble({super.key, required this.name});

  @override
  State<GroupChatTypingBubble> createState() => _GroupChatTypingBubbleState();
}

class _GroupChatTypingBubbleState extends State<GroupChatTypingBubble>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animations = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: -5,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppAvatar(initials: widget.name, size: 24, shape: BoxShape.circle),
        const SizedBox(width: AppSpacing.xs + 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Padding(
                padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                child: AnimatedBuilder(
                  animation: _animations[i],
                  builder: (ctx, child) => Transform.translate(
                    offset: Offset(0, _animations[i].value),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: ctx.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── User file bubble (real picked image + optional caption) ─────────────────

class GroupChatUserFileBubble extends StatelessWidget {
  final String filePath;
  final String? caption;
  const GroupChatUserFileBubble({
    super.key,
    required this.filePath,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => _showFileImageModal(context, filePath),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(filePath),
                width: 109,
                height: 128,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.surfaceMuted,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(3),
                ),
              ),
              child: Text(
                caption!,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textQuaternary,
                  fontSize: 14,
                  fontVariations: const [FontVariation('wght', 400)],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Image modal ──────────────────────────────────────────────────────────────

void _showFileImageModal(BuildContext context, String filePath) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (ctx) => _FileImageModal(filePath: filePath),
  );
}

class _FileImageModal extends StatelessWidget {
  final String filePath;
  const _FileImageModal({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            Center(
              child: InteractiveViewer(
                child: Image.file(File(filePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showImageModal(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (ctx) => _ImageModal(imagePath: imagePath),
  );
}

class _ImageModal extends StatelessWidget {
  final String imagePath;
  const _ImageModal({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            Center(
              child: InteractiveViewer(
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          AppIcons.download,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Download',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontVariations: const [FontVariation('wght', 500)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

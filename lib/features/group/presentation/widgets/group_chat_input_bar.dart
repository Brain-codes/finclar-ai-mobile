import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

class GroupChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachment;
  final VoidCallback? onCamera;

  const GroupChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttachment,
    this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.sm + bottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: context.scaffoldColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textQuaternary,
                        fontSize: 14,
                        fontVariations: const [FontVariation('wght', 400)],
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        fillColor: Colors.transparent,
                        hintStyle: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onAttachment,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        AppIcons.link,
                        size: 20,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCamera,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        AppIcons.camera,
                        size: 20,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.send2,
                size: 20,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

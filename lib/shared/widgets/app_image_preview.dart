import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../icons/app_icons.dart';

Future<void> showImagePreview(
  BuildContext context, {
  File? file,
  String? url,
}) {
  if (file == null && (url == null || url.isEmpty)) return Future.value();
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.black.withValues(alpha: 0.9),
    builder: (_) => AppImagePreview(file: file, url: url),
  );
}

class AppImagePreview extends StatelessWidget {
  final File? file;
  final String? url;

  const AppImagePreview({super.key, this.file, this.url});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: SizedBox.expand(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: file != null
                    ? Image.file(file!, fit: BoxFit.contain)
                    : CachedNetworkImage(
                        imageUrl: url!,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const Center(
                          child: CupertinoActivityIndicator(
                            color: AppColors.white,
                          ),
                        ),
                        errorWidget: (_, _, _) => const Center(
                          child: Icon(
                            AppIcons.file,
                            size: 48,
                            color: AppColors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.base,
            right: AppSpacing.screenPadding,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.close,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

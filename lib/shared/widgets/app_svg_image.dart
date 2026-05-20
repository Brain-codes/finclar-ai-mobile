import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// The only widget allowed to render SVGs in the app.
// Never import flutter_svg directly in feature or shared code —
// always go through this widget.
//
// Usage:
//   AppSvgImage(AppSvg.google, width: 24, height: 24)
//   AppSvgImage(AppSvg.logo, color: AppColors.primary)
//   AppSvgImage.network('https://...', width: 32)
class AppSvgImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final bool _isNetwork;

  // Asset SVG (from assets/svg/ — use AppSvg.* for the path)
  const AppSvgImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  }) : _isNetwork = false;

  // Network SVG (e.g. remotely loaded icons or avatars)
  const AppSvgImage.network(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  }) : _isNetwork = true;

  @override
  Widget build(BuildContext context) {
    final colorFilter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null;

    if (_isNetwork) {
      return SvgPicture.network(
        path,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter,
        placeholderBuilder: (_) => SizedBox(width: width, height: height),
      );
    }

    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      colorFilter: colorFilter,
    );
  }
}

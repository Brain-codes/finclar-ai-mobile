import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../icons/app_icons.dart';
import 'app_svg_image.dart';

/// A versatile avatar widget supporting initials, network images, SVGs, and icons.
///
/// Priority: [imageUrl] → [svgAsset] → [svgNetwork] → [icon] → [initials] → fallback icon
///
/// Color logic:
/// - Pass [backgroundColor] + [foregroundColor] for full control.
/// - Pass only [color] → bg = color at 15% opacity, fg = color.
/// - Pass nothing → a stable pastel is derived from [initials] or [icon]'s hash.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.initials,
    this.imageUrl,
    this.svgAsset,
    this.svgNetwork,
    this.icon,
    this.size = 40,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.circle,
    this.backgroundColor,
    this.foregroundColor,
    this.color,
    this.border,
  });

  /// Text used to generate initials (e.g. "John Doe" → "JD").
  final String? initials;

  /// Remote image URL. Shown with a loading spinner and error fallback.
  final String? imageUrl;

  /// Local SVG asset path (e.g. `AppSvg.google`). Rendered via [AppSvgImage].
  final String? svgAsset;

  /// Remote SVG URL. Rendered via [AppSvgImage.network].
  final String? svgNetwork;

  /// Icon to show when no higher-priority content is provided, or as fallback.
  final IconData? icon;

  /// Uniform size. Overridden by [width]/[height] if both are provided.
  final double size;

  /// Explicit width. Defaults to [size].
  final double? width;

  /// Explicit height. Defaults to [size].
  final double? height;

  /// Corner radius when [shape] is [BoxShape.rectangle]. Ignored for circle.
  /// Defaults to a fully rounded rectangle when shape is rectangle.
  final double? borderRadius;

  /// [BoxShape.circle] (default) or [BoxShape.rectangle].
  final BoxShape shape;

  /// Explicit background color. Overrides auto-color logic.
  final Color? backgroundColor;

  /// Explicit foreground (text/icon/SVG tint) color. Overrides auto-color logic.
  final Color? foregroundColor;

  /// Convenience color: bg = color.withOpacity(0.15), fg = color.
  /// Ignored when [backgroundColor] and [foregroundColor] are both provided.
  final Color? color;

  /// Optional border.
  final BoxBorder? border;

  // ─── Pastel palette for auto-color (mild, works on both light/dark) ─────────
  static const List<Color> _palette = [
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFF14B8A6), // teal
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF3B82F6), // blue
    Color(0xFFF97316), // orange
    Color(0xFF84CC16), // lime
    Color(0xFF06B6D4), // cyan
    Color(0xFFEC4899), // pink
  ];

  String get _resolvedInitials {
    final raw = initials?.trim() ?? '';
    if (raw.isEmpty) return '';
    final parts = raw.split(RegExp(r'\s+'));
    return parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  Color _resolvedBg(Color fg) =>
      backgroundColor ??
      color?.withValues(alpha: 0.15) ??
      fg.withValues(alpha: 0.15);

  Color _resolvedFg() {
    if (foregroundColor != null) return foregroundColor!;
    if (color != null) return color!;
    final seed = initials ?? icon?.codePoint.toString() ?? '';
    final index = seed.isEmpty ? 0 : seed.hashCode.abs() % _palette.length;
    return _palette[index];
  }

  double get _width => width ?? size;
  double get _height => height ?? size;

  BorderRadius? get _resolvedBorderRadius {
    if (shape == BoxShape.circle) return null;
    final r = borderRadius ?? _width / 2;
    return BorderRadius.circular(r);
  }

  @override
  Widget build(BuildContext context) {
    final fg = _resolvedFg();
    final bg = _resolvedBg(fg);
    final initStr = _resolvedInitials;
    final fontSize = (_width * 0.35).clamp(10.0, 22.0);

    // imageUrl gets a transparent bg shell; the CachedNetworkImage fills it
    final shellBg = imageUrl != null && imageUrl!.isNotEmpty
        ? Colors.transparent
        : bg;

    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: shellBg,
        shape: shape,
        borderRadius: _resolvedBorderRadius,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(fg, bg, initStr, fontSize),
    );
  }

  Widget _buildContent(Color fg, Color bg, String initStr, double fontSize) {
    // 1. Network image with cache + loading spinner + fallback
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: _width,
        height: _height,
        placeholder: (context, url) => _coloredBox(
          bg,
          const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            _coloredBox(bg, _staticContent(fg, initStr, fontSize)),
      );
    }

    // 2. Local SVG asset
    if (svgAsset != null && svgAsset!.isNotEmpty) {
      return _coloredBox(
        bg,
        Center(
          child: AppSvgImage(
            svgAsset!,
            width: _width * 0.55,
            height: _height * 0.55,
            color: fg,
          ),
        ),
      );
    }

    // 3. Network SVG
    if (svgNetwork != null && svgNetwork!.isNotEmpty) {
      return _coloredBox(
        bg,
        Center(
          child: AppSvgImage.network(
            svgNetwork!,
            width: _width * 0.55,
            height: _height * 0.55,
            color: fg,
          ),
        ),
      );
    }

    // 4. Icon / initials / fallback
    return _coloredBox(bg, _staticContent(fg, initStr, fontSize));
  }

  Widget _coloredBox(Color bg, Widget child) =>
      Container(color: bg, width: _width, height: _height, child: child);

  Widget _staticContent(Color fg, String initStr, double fontSize) {
    if (initStr.isNotEmpty) {
      return Center(
        child: Text(
          initStr,
          style: AppTypography.bodySmall.copyWith(
            color: fg,
            fontSize: fontSize,
            fontVariations: const [FontVariation('wght', 600)],
            height: 1,
          ),
        ),
      );
    }

    return Center(
      child: Icon(icon ?? AppIcons.user, color: fg, size: _width * 0.45),
    );
  }
}

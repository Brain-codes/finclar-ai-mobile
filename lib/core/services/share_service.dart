import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'logger_service.dart';

/// The only place `share_plus` is used. Feature code shares through here so the
/// package can be swapped without touching screens.
class ShareService {
  ShareService._();

  /// Rasterises the subtree behind [boundaryKey] to PNG bytes. The widget must
  /// be wrapped in a [RepaintBoundary] carrying that key and be on screen.
  static Future<Uint8List?> captureAsPng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3,
  }) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // A boundary that hasn't painted yet rasterises as a blank frame.
      if (boundary.debugNeedsPaint) {
        await Future<void>.delayed(const Duration(milliseconds: 32));
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data?.buffer.asUint8List();
    } catch (e, st) {
      Log.e('Failed to capture widget as PNG', error: e, stackTrace: st);
      return null;
    }
  }

  /// Shares raw image bytes as a file. [fileName] must carry the extension —
  /// iOS decides how to preview the attachment from it.
  static Future<bool> shareImage(
    Uint8List bytes, {
    required String fileName,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: text,
          subject: subject,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (e, st) {
      Log.e('Failed to share image', error: e, stackTrace: st);
      return false;
    }
  }

  /// Global rect of [context]'s box, for anchoring the iPad share popover.
  static Rect? originFrom(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

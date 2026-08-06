import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'logger_service.dart';

class _CompressRequest {
  final String path;
  final String outPath;
  final int maxDimension;
  final int maxBytes;

  const _CompressRequest({
    required this.path,
    required this.outPath,
    required this.maxDimension,
    required this.maxBytes,
  });
}

/// Shrinks images before upload. The server rejects multipart bodies over 3MB
/// with a 413, so anything above that is squeezed under the limit first.
class ImageCompressionService {
  static const int _maxDimension = 2400;

  /// Files at or below this sail through untouched — it is the server's limit.
  static const int _compressAboveBytes = 3 * 1024 * 1024;

  /// Compression target, kept under the limit so multipart overhead still fits.
  static const int _maxBytes = 2800 * 1024;

  /// Set to false to upload originals untouched (e.g. to test whether the
  /// server, not the image, is at fault).
  static bool enabled = true;

  /// Returns a compressed copy in the temp directory, or the original file if
  /// it is already small enough or cannot be decoded.
  static Future<File> compress(
    File file, {
    int maxDimension = _maxDimension,
    int maxBytes = _maxBytes,
    int compressAboveBytes = _compressAboveBytes,
  }) async {
    if (!enabled) return file;
    try {
      final originalBytes = await file.length();
      if (originalBytes <= compressAboveBytes) return file;

      final dir = await getTemporaryDirectory();
      final outPath = p.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}_'
        '${p.basenameWithoutExtension(file.path)}.jpg',
      );

      final result = await compute(
        _compressInIsolate,
        _CompressRequest(
          path: file.path,
          outPath: outPath,
          maxDimension: maxDimension,
          maxBytes: maxBytes,
        ),
      );
      if (result == null) return file;

      final out = File(result);
      Log.d(
        '[ImageCompression] ${_kb(originalBytes)} → ${_kb(await out.length())}',
      );
      return out;
    } catch (e, st) {
      Log.e('[ImageCompression] Failed — uploading original',
          error: e, stackTrace: st);
      return file;
    }
  }

  /// [compress] + [MultipartFile] in one step — the form of this used by every
  /// repository that uploads an image.
  static Future<MultipartFile> multipart(File file) async {
    final compressed = await compress(file);
    // Declare the type explicitly — the default is application/octet-stream,
    // which server-side image processing can refuse to decode.
    return MultipartFile.fromFile(
      compressed.path,
      filename: p.basename(compressed.path),
      contentType: DioMediaType('image', _subtype(compressed.path)),
    );
  }

  static String _subtype(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.png') return 'png';
    if (ext == '.heic') return 'heic';
    if (ext == '.webp') return 'webp';
    return 'jpeg';
  }

  static String _kb(int bytes) => '${(bytes / 1024).round()}KB';
}

String? _compressInIsolate(_CompressRequest req) {
  final decoded = img.decodeImage(File(req.path).readAsBytesSync());
  if (decoded == null) return null;

  final longest = decoded.width > decoded.height ? decoded.width : decoded.height;
  final image = longest > req.maxDimension
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? req.maxDimension : null,
          height: decoded.height > decoded.width ? req.maxDimension : null,
          interpolation: img.Interpolation.average,
        )
      : decoded;

  // Step the quality down until the encoded size fits. The floor stays high —
  // pickers already hand us a re-encoded JPEG, and a second aggressive pass
  // smears the fine text that receipt OCR depends on.
  List<int> encoded = const [];
  for (final quality in const [92, 85, 78, 70]) {
    encoded = img.encodeJpg(image, quality: quality);
    if (encoded.length <= req.maxBytes) break;
  }

  File(req.outPath).writeAsBytesSync(encoded);
  return req.outPath;
}

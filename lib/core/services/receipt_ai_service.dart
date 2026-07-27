import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import '../../features/expenses/data/models/scanned_receipt_model.dart';
import 'logger_service.dart';

/// Interprets a receipt photo with a vision LLM (OpenAI) and returns a
/// structured [ScannedReceiptModel]. Replaces the old on-device ML Kit OCR.
///
/// The API key is injected at build time via `--dart-define=OPENAI_API_KEY=...`.
/// This is intentionally a separate Dio instance (different host + auth) from
/// the app's [ApiClient].
class ReceiptAiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.openAiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // Categories the model must choose from (mirror the backend's category set).
  static const _categories =
      'Food, Transportation, Health, Shopping, Utilities, '
      'Entertainment, Education, Rent, Investment, Other';

  static Future<ScannedReceiptModel> scanReceipt(File imageFile) async {
    if (AppConstants.openAiApiKey.isEmpty) {
      Log.e('[ReceiptAI] OPENAI_API_KEY not set — pass it via --dart-define');
      throw const AppException('AI scanning is not configured');
    }

    Log.i('[ReceiptAI] Scanning receipt: ${imageFile.path}');
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mime = _mimeFor(imageFile.path);

    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': AppConstants.openAiModel,
          'response_format': {'type': 'json_object'},
          'max_tokens': 1500,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': _userPrompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:$mime;base64,$base64Image'},
                },
              ],
            },
          ],
        },
      );

      final content = response.data['choices'][0]['message']['content'] as String;
      Log.d('[ReceiptAI] Raw model JSON: $content');
      final receipt = _parse(content, imageFile.path);

      if (receipt.items.isEmpty) {
        Log.w('[ReceiptAI] No items extracted — treating as failed scan');
        throw const AppException('Could not read this receipt');
      }
      Log.i('[ReceiptAI] Done — merchant: "${receipt.merchantName}", '
          'items: ${receipt.items.length}, total: ${receipt.totalAmount}');
      return receipt;
    } on DioException catch (e, st) {
      Log.e('[ReceiptAI] Request failed', error: e, stackTrace: st);
      throw const AppException('Could not scan receipt. Please try again.');
    }
  }

  static const _systemPrompt =
      'You are a receipt-parsing assistant. You receive a photo of a purchase '
      'receipt and extract its contents as strict JSON. Only return JSON.';

  static String get _userPrompt => '''
Extract the receipt in this image as a JSON object with this exact shape:
{
  "merchant": "string (store/vendor name, or 'Receipt' if unknown)",
  "total": number (grand total),
  "items": [
    {
      "name": "string",
      "quantity": integer (default 1),
      "unit_price": number,
      "amount": number (line total = quantity * unit_price),
      "category": "one of: $_categories"
    }
  ]
}
Rules:
- Use plain numbers (no currency symbols or thousands separators).
- Pick the single best category for each item from the list.
- If the image is not a readable receipt, return {"merchant":"Receipt","total":0,"items":[]}.
Return only the JSON object.''';

  static ScannedReceiptModel _parse(String content, String imagePath) {
    final Map<String, dynamic> json = jsonDecode(content);
    final rawItems = (json['items'] as List<dynamic>? ?? []);

    final items = <ScannedItemModel>[];
    for (var i = 0; i < rawItems.length; i++) {
      final m = rawItems[i] as Map<String, dynamic>;
      final qty = (m['quantity'] as num?)?.toInt() ?? 1;
      final amount = _num(m['amount']);
      final unitPrice = m['unit_price'] != null
          ? _num(m['unit_price'])
          : (qty > 0 ? amount / qty : amount);
      final name = (m['name'] as String?)?.trim() ?? '';
      if (name.isEmpty || amount <= 0) continue;
      items.add(ScannedItemModel(
        id: '${DateTime.now().microsecondsSinceEpoch}_$i',
        name: name,
        category: (m['category'] as String?)?.trim().isNotEmpty == true
            ? m['category'] as String
            : 'Other',
        amount: amount,
        quantity: qty,
        unitPrice: unitPrice,
      ));
    }

    final declaredTotal = _num(json['total']);
    final computedTotal = items.fold<double>(0, (s, e) => s + e.amount);

    return ScannedReceiptModel(
      merchantName: (json['merchant'] as String?)?.trim().isNotEmpty == true
          ? json['merchant'] as String
          : 'Receipt',
      totalAmount: declaredTotal > 0 ? declaredTotal : computedTotal,
      imagePath: imagePath,
      items: items,
    );
  }

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '')) ?? 0;
  }

  static String _mimeFor(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.heic') || p.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }
}

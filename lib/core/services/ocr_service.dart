import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../features/expenses/data/models/scanned_receipt_model.dart';
import 'logger_service.dart';

class OcrService {
  static Future<ScannedReceiptModel> scanReceipt(File imageFile) async {
    Log.i('[OCR] Starting scan — image: ${imageFile.path}');
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFile(imageFile);
      final result = await recognizer.processImage(input);
      Log.d('[OCR] Raw text extracted (${result.text.length} chars):\n${result.text}');
      final receipt = _parse(result.text, imageFile.path);
      if (receipt.items.isEmpty) {
        Log.w('[OCR] Parsing produced 0 items — throwing to trigger failed state');
        throw Exception('No items detected');
      }
      Log.i('[OCR] Scan complete — merchant: "${receipt.merchantName}", items: ${receipt.items.length}, total: ${receipt.totalAmount}');
      return receipt;
    } catch (e, st) {
      Log.e('[OCR] Scan failed', error: e, stackTrace: st);
      rethrow;
    } finally {
      recognizer.close();
    }
  }

  static ScannedReceiptModel _parse(String rawText, String imagePath) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    Log.d('[OCR] Parsing ${lines.length} non-empty lines');

    final merchantName =
        lines.isNotEmpty ? _extractMerchantName(lines) : 'Receipt';
    Log.d('[OCR] Merchant name: "$merchantName"');

    final items = _extractItems(lines);
    final total = items.fold<double>(0.0, (s, i) => s + i.amount);

    Log.d('[OCR] Items parsed: ${items.length}, computed total: $total');

    return ScannedReceiptModel(
      merchantName: merchantName,
      totalAmount: total,
      imagePath: imagePath,
      items: items,
    );
  }

  static String _extractMerchantName(List<String> lines) {
    for (final line in lines.take(5)) {
      if (line.length < 3) continue;
      if (RegExp(r'^\d').hasMatch(line)) continue;
      return _titleCase(line);
    }
    return _titleCase(lines.first);
  }

  static List<ScannedItemModel> _extractItems(List<String> lines) {
    // Step 1 — find the item block boundaries so we ignore header/footer lines
    final start = _findItemBlockStart(lines);
    final end = _findItemBlockEnd(lines, start);

    Log.d('[OCR] Item block: lines $start–$end of ${lines.length}');
    Log.d('[OCR] Item block contents:\n${lines.sublist(start, end).join('\n')}');

    final itemLines = lines.sublist(start, end);
    final items = <ScannedItemModel>[];

    // Matches a price token: must have either comma-grouping OR a decimal
    // e.g. "1,140.00" "380.00" "₦5,000" — but NOT bare ints like "50" "001" "2028"
    final priceToken = RegExp(
      r'[₦#]?\s*(\d{1,3}(?:,\d{3})+(?:\.\d{1,2})?|\d+\.\d{1,2})',
    );

    // Leading qty: a line that starts with an integer before the product name
    // e.g. "3 INDOMIE ONION CH ..." — but only if what follows contains a letter
    final leadingQtyRe = RegExp(r'^(\d+)\s+(.+)$');

    // Inline "3 x" / "x 3" quantity markers
    final qtyMarkerPrefix = RegExp(r'^(\d+)\s*[xX×]\s+(.+)$');
    final qtyMarkerSuffix = RegExp(r'^(.+?)\s+(\d+)\s*[xX×]\s*$');

    for (int i = 0; i < itemLines.length; i++) {
      final line = itemLines[i];
      if (line.length < 3) continue;

      // Collect every price token on this line
      final allPrices = priceToken.allMatches(line).toList();
      if (allPrices.isEmpty) {
        Log.d('[OCR] No price token, skipping: "$line"');
        continue;
      }

      // The LAST price is the line total (AMOUNT column)
      final totalMatch = allPrices.last;
      final totalAmount = double.tryParse(
        totalMatch.group(1)!.replaceAll(',', ''),
      );
      if (totalAmount == null || totalAmount < 10) {
        Log.d('[OCR] Total too small, skipping: "$line"');
        continue;
      }

      // Everything to the LEFT of the total price
      var leftText = line.substring(0, totalMatch.start).trimRight();

      // Strip receipt leader chars (dots/dashes used for visual spacing)
      leftText = leftText.replaceAll(RegExp(r'[\.\-_]+$'), '').trimRight();

      // If a UNIT PRICE column sits right before the total (e.g. "380.00 1,140.00"),
      // strip it — we only want the product name and qty
      final trailingUnitPrice = RegExp(
        r'\s+[₦#]?\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?$|\s+[₦#]?\d+\.\d{1,2}$',
      );
      final unitPriceMatch = trailingUnitPrice.firstMatch(leftText);
      if (unitPriceMatch != null) {
        Log.d('[OCR] Stripped unit price: "${unitPriceMatch.group(0)!.trim()}" from "$leftText"');
        leftText = leftText.substring(0, unitPriceMatch.start).trimRight();
      }

      // Must have at least one letter left
      if (leftText.length < 2 || !leftText.contains(RegExp(r'[a-zA-Z]'))) {
        Log.d('[OCR] No letters in item text, skipping: "$line"');
        continue;
      }

      int qty = 1;
      double unitPrice = totalAmount;
      String finalName = leftText;

      // Check inline qty markers first ("3 x ITEM" / "ITEM x 3")
      final prefixMarker = qtyMarkerPrefix.firstMatch(leftText);
      final suffixMarker = qtyMarkerSuffix.firstMatch(leftText);

      if (prefixMarker != null) {
        qty = int.tryParse(prefixMarker.group(1)!) ?? 1;
        finalName = prefixMarker.group(2)!.trim();
        unitPrice = totalAmount / qty;
        Log.d('[OCR] Qty marker prefix: $qty x "$finalName"');
      } else if (suffixMarker != null) {
        qty = int.tryParse(suffixMarker.group(2)!) ?? 1;
        finalName = suffixMarker.group(1)!.trim();
        unitPrice = totalAmount / qty;
        Log.d('[OCR] Qty marker suffix: $qty x "$finalName"');
      } else {
        // Check for a leading bare integer as qty (e.g. "3 INDOMIE ONION CH")
        final leadingMatch = leadingQtyRe.firstMatch(leftText.trim());
        if (leadingMatch != null) {
          final candidateQty = int.tryParse(leadingMatch.group(1)!);
          final candidateName = leadingMatch.group(2)!.trim();
          // Only treat it as qty if the rest is a real product name (has letters)
          if (candidateQty != null &&
              candidateQty <= 99 &&
              candidateName.contains(RegExp(r'[a-zA-Z]'))) {
            qty = candidateQty;
            finalName = candidateName;
            unitPrice = totalAmount / qty;
            Log.d('[OCR] Leading qty: $qty x "$finalName"');
          }
        }
      }

      if (finalName.length < 2) continue;

      Log.d('[OCR] ✓ "$finalName" | qty: $qty | unit: $unitPrice | total: $totalAmount | cat: ${_guessCategory(finalName)}');

      items.add(ScannedItemModel(
        id: '${DateTime.now().microsecondsSinceEpoch}_$i',
        name: _titleCase(finalName),
        category: _guessCategory(finalName),
        amount: totalAmount,
        quantity: qty,
        unitPrice: unitPrice,
      ));
    }

    return items;
  }

  // Finds where items start: after a column-header row (QTY / ITEM / PRICE / AMOUNT)
  // or, if none found, after the receipt metadata block (first ~5 lines).
  static int _findItemBlockStart(List<String> lines) {
    final columnHeader = RegExp(
      r'\b(qty|item|items|description|product|goods|article)\b',
      caseSensitive: false,
    );
    for (int i = 0; i < lines.length; i++) {
      if (columnHeader.hasMatch(lines[i])) {
        Log.d('[OCR] Column header found at line $i: "${lines[i]}"');
        return i + 1;
      }
    }
    // No explicit header — skip the first 4 lines (store name, address, date, receipt no)
    Log.d('[OCR] No column header found, defaulting item block start to line 4');
    return lines.length > 4 ? 4 : 0;
  }

  // Finds where items end: at the first footer line (SUBTOTAL, TOTAL, etc.)
  static int _findItemBlockEnd(List<String> lines, int startIdx) {
    final footerPattern = RegExp(
      r'\b(subtotal|sub.total|total|tax|vat|change|cash|discount|balance|amount due|grand)\b',
      caseSensitive: false,
    );
    for (int i = startIdx; i < lines.length; i++) {
      if (footerPattern.hasMatch(lines[i])) {
        Log.d('[OCR] Footer found at line $i: "${lines[i]}"');
        return i;
      }
    }
    return lines.length;
  }

  static String _titleCase(String s) {
    return s
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String _guessCategory(String name) {
    final n = name.toLowerCase();

    const food = [
      'rice', 'chicken', 'beef', 'fish', 'egg', 'bread', 'milk', 'yam',
      'tomato', 'onion', 'pepper', 'flour', 'sugar', 'salt', 'oil', 'drink',
      'juice', 'food', 'snack', 'biscuit', 'noodle', 'pasta', 'vegetable',
      'fruit', 'meat', 'sauce', 'indomie', 'malt', 'maltina', 'coke', 'fanta',
      'sprite', 'butter', 'cheese', 'yoghurt', 'cereal', 'oat', 'soda',
      'beer', 'wine', 'chocolate', 'candy', 'basmati', 'spaghetti', 'welch',
    ];
    const transport = [
      'petrol', 'fuel', 'gas', 'transport', 'uber', 'taxi', 'bus', 'fare',
      'toll', 'parking', 'diesel',
    ];
    const health = [
      'medicine', 'drug', 'tablet', 'capsule', 'cream', 'pharmacy',
      'hospital', 'clinic', 'health', 'medical', 'paracetamol', 'syrup',
      'bandage', 'vitamin',
    ];
    const utilities = [
      'soap', 'detergent', 'tissue', 'toilet', 'cleaning', 'bleach',
      'electricity', 'internet', 'cable', 'subscription', 'airtime', 'data',
      'bill', 'wash', 'liquid', 'sanitizer', 'fabuloso', 'pinky', 'dettol',
    ];
    const shopping = [
      'shirt', 'shoes', 'bag', 'cloth', 'trouser', 'dress', 'fashion',
      'accessory', 'electronics', 'phone', 'laptop', 'singlet', 'cap', 'hat',
      'sock', 'zara', 'wear',
    ];

    if (food.any((k) => n.contains(k))) return 'Food';
    if (transport.any((k) => n.contains(k))) return 'Transport';
    if (health.any((k) => n.contains(k))) return 'Health';
    if (utilities.any((k) => n.contains(k))) return 'Utilities';
    if (shopping.any((k) => n.contains(k))) return 'Shopping';
    return 'Shopping';
  }
}

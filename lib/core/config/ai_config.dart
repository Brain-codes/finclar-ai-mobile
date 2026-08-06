/// How receipt scanning interprets the photo.
///
/// - [openai]  → on-device: photo is sent straight to OpenAI vision
///   (`ReceiptAiService`), parsed locally into editable items, then the user
///   reviews/edits before saving. Key ships in the app (dev/MVP only).
/// - [backend] → photo is uploaded to our own `POST /expenses/receipt`, which
///   runs the AI server-side and **creates the expense directly** (secure;
///   no key in the app). The user lands on the created expense's detail screen.
enum ReceiptScanSource { openai, backend }

abstract class AiConfig {
  /// Single switch for the receipt-scanning implementation.
  ///
  /// Defaults to [backend]: the server owns the AI key and returns real,
  /// actionable error messages, which the on-device OpenAI path cannot.
  /// Override at build time to go back to on-device scanning:
  ///   --dart-define=RECEIPT_SCAN_SOURCE=openai
  static const ReceiptScanSource receiptScanSource =
      _fromEnv == 'openai' ? ReceiptScanSource.openai : ReceiptScanSource.backend;

  static const String _fromEnv =
      String.fromEnvironment('RECEIPT_SCAN_SOURCE', defaultValue: 'backend');
}

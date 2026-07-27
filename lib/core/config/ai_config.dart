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
  /// Flip this to change which path the camera flow uses.
  /// Can also be overridden at build time:
  ///   --dart-define=RECEIPT_SCAN_SOURCE=backend
  static const ReceiptScanSource receiptScanSource =
      _fromEnv == 'backend' ? ReceiptScanSource.backend : ReceiptScanSource.openai;

  static const String _fromEnv =
      String.fromEnvironment('RECEIPT_SCAN_SOURCE', defaultValue: 'openai');
}

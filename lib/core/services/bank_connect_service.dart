import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:mono_flutter/mono_flutter.dart';
import '../constants/app_constants.dart';
import 'logger_service.dart';

enum BankConnectStatus { success, cancelled, notConfigured }

class BankConnectResult {
  final BankConnectStatus status;
  final String? code;

  const BankConnectResult(this.status, {this.code});
}

/// Wraps the Mono Connect widget. UI/providers never touch the SDK directly
/// (same pattern as BiometricService / SocialAuthService).
class BankConnectService {
  const BankConnectService._();

  static bool get isConfigured => AppConstants.monoPublicKey.isNotEmpty;

  /// Launches Mono Connect. Resolves with the one-time auth code Mono returns,
  /// which the backend exchanges via POST /banks/link.
  ///
  /// We do NOT pre-select the institution: Mono's institution id differs from
  /// our backend's NIP `code`, so we let Mono show its own bank picker.
  static Future<BankConnectResult> launch(
    BuildContext context, {
    required String customerName,
    required String customerEmail,
  }) async {
    if (!isConfigured) {
      Log.e('Mono public key not set (MONO_PUBLIC_KEY)');
      return const BankConnectResult(BankConnectStatus.notConfigured);
    }

    // mono_flutter's launch() pushes a route but does NOT return a Future that
    // awaits the modal — so we drive completion off its callbacks instead.
    final completer = Completer<BankConnectResult>();

    MonoFlutter().launch(
      context,
      AppConstants.monoPublicKey,
      reference: DateTime.now().millisecondsSinceEpoch.toString(),
      scope: 'auth',
      customer: MonoCustomer(
        newCustomer: MonoNewCustomerModel(
          name: customerName,
          email: customerEmail,
        ),
      ),
      onEvent: (event, data) => Log.d('Mono event: $event'),
      onSuccess: (c) {
        Log.d('Mono Connect success');
        if (!completer.isCompleted) {
          completer.complete(
            BankConnectResult(BankConnectStatus.success, code: c),
          );
        }
      },
      onClosed: (_) {
        Log.d('Mono Connect closed');
        // Closed without a success → user cancelled. (onSuccess fires first on
        // a successful link, so this is a no-op in that case.)
        if (!completer.isCompleted) {
          completer.complete(
            const BankConnectResult(BankConnectStatus.cancelled),
          );
        }
      },
    );

    return completer.future;
  }
}

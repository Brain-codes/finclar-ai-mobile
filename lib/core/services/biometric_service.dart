import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'storage_service.dart';
import 'logger_service.dart';

enum BiometricResult {
  success,
  failed,
  notAvailable,
  notEnrolled,
  lockedOut,
  cancelled,
}

class BiometricService {
  BiometricService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (e, st) {
      Log.e('Biometric availability check failed', error: e, stackTrace: st);
      return false;
    }
  }

  static Future<bool> hasEnrolledBiometrics() async {
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e, st) {
      Log.e('Biometric enrollment check failed', error: e, stackTrace: st);
      return false;
    }
  }

  static Future<bool> isEnabled() => StorageService.isBiometricEnabled();

  static Future<void> setEnabled(bool enabled) =>
      StorageService.setBiometricEnabled(enabled);

  static Future<BiometricResult> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return ok ? BiometricResult.success : BiometricResult.failed;
    } on Exception catch (e, st) {
      Log.e('Biometric authentication error', error: e, stackTrace: st);
      return _mapError(e);
    }
  }

  static BiometricResult _mapError(Exception e) {
    final code = e is PlatformException ? e.code : '';
    return switch (code) {
      auth_error.notAvailable => BiometricResult.notAvailable,
      auth_error.notEnrolled => BiometricResult.notEnrolled,
      auth_error.lockedOut ||
      auth_error.permanentlyLockedOut =>
        BiometricResult.lockedOut,
      _ => BiometricResult.failed,
    };
  }
}

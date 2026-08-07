import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'logger_service.dart';

enum SocialAuthOutcome { success, cancelled, failed }

class SocialAuthResult {
  final SocialAuthOutcome outcome;
  final String? firebaseToken;
  final String? error;

  /// The underlying provider/platform error, kept verbatim so the failure sheet
  /// can show what actually went wrong. Never shown as the headline message.
  final String? details;

  const SocialAuthResult._(
    this.outcome, {
    this.firebaseToken,
    this.error,
    this.details,
  });

  factory SocialAuthResult.success(String token) =>
      SocialAuthResult._(SocialAuthOutcome.success, firebaseToken: token);
  static const SocialAuthResult cancelled =
      SocialAuthResult._(SocialAuthOutcome.cancelled);
  factory SocialAuthResult.failed(String message, {String? details}) =>
      SocialAuthResult._(
        SocialAuthOutcome.failed,
        error: message,
        details: details,
      );
}

/// Unpacks the error types the sign-in SDKs actually throw into something a
/// human can read. `toString()` on these hides the code, which is the one part
/// that identifies the failure (e.g. `sign_in_failed 10` = SHA-1 mismatch).
String describeAuthError(Object e) {
  if (e is FirebaseAuthException) {
    final parts = <String>[
      'FirebaseAuthException',
      'code: ${e.code}',
      if (e.message != null) 'message: ${e.message}',
      if (e.plugin.isNotEmpty) 'plugin: ${e.plugin}',
    ];
    return parts.join('\n');
  }
  if (e is PlatformException) {
    final parts = <String>[
      'PlatformException',
      'code: ${e.code}',
      if (e.message != null) 'message: ${e.message}',
      if (e.details != null) 'details: ${e.details}',
    ];
    return parts.join('\n');
  }
  return '${e.runtimeType}\n$e';
}

class SocialAuthService {
  SocialAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _google = GoogleSignIn();

  static Future<SocialAuthResult> signInWithGoogle() async {
    try {
      await _google.signOut();
      final account = await _google.signIn();
      if (account == null) return SocialAuthResult.cancelled;

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      return _exchangeFirebaseCredential(credential);
    } catch (e, st) {
      Log.e('Google sign-in failed', error: e, stackTrace: st);
      return SocialAuthResult.failed(
        'Could not sign in with Google',
        details: describeAuthError(e),
      );
    }
  }

  static Future<SocialAuthResult> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauth = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      return _exchangeFirebaseCredential(oauth);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return SocialAuthResult.cancelled;
      }
      Log.e('Apple sign-in failed', error: e);
      return SocialAuthResult.failed(
        'Could not sign in with Apple',
        details: 'AuthorizationError ${e.code.name}\n${e.message}',
      );
    } catch (e, st) {
      Log.e('Apple sign-in failed', error: e, stackTrace: st);
      return SocialAuthResult.failed(
        'Could not sign in with Apple',
        details: describeAuthError(e),
      );
    }
  }

  static Future<SocialAuthResult> _exchangeFirebaseCredential(
    AuthCredential credential,
  ) async {
    final userCred = await _auth.signInWithCredential(credential);
    final token = await userCred.user?.getIdToken();
    if (token == null) {
      return SocialAuthResult.failed(
        'Could not retrieve authentication token',
        details: 'Firebase returned a user with no ID token '
            '(uid: ${userCred.user?.uid ?? "null"}).',
      );
    }
    return SocialAuthResult.success(token);
  }

  static Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _google.signOut()]);
    } catch (e, st) {
      Log.e('Social sign-out failed', error: e, stackTrace: st);
    }
  }
}

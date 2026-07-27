import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'logger_service.dart';

enum SocialAuthOutcome { success, cancelled, failed }

class SocialAuthResult {
  final SocialAuthOutcome outcome;
  final String? firebaseToken;
  final String? error;

  const SocialAuthResult._(this.outcome, {this.firebaseToken, this.error});

  factory SocialAuthResult.success(String token) =>
      SocialAuthResult._(SocialAuthOutcome.success, firebaseToken: token);
  static const SocialAuthResult cancelled =
      SocialAuthResult._(SocialAuthOutcome.cancelled);
  factory SocialAuthResult.failed(String message) =>
      SocialAuthResult._(SocialAuthOutcome.failed, error: message);
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
      return SocialAuthResult.failed('Could not sign in with Google');
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
      return SocialAuthResult.failed('Could not sign in with Apple');
    } catch (e, st) {
      Log.e('Apple sign-in failed', error: e, stackTrace: st);
      return SocialAuthResult.failed('Could not sign in with Apple');
    }
  }

  static Future<SocialAuthResult> _exchangeFirebaseCredential(
    AuthCredential credential,
  ) async {
    final userCred = await _auth.signInWithCredential(credential);
    final token = await userCred.user?.getIdToken();
    if (token == null) {
      return SocialAuthResult.failed('Could not retrieve authentication token');
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/auth_state_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/session_reset.dart';
import '../../../core/services/social_auth_service.dart';
import 'auth_repository_provider.dart';
import 'user_profile_provider.dart';

enum SocialProvider { google, apple }

class SocialAuthFailure {
  final SocialProvider provider;
  final String message;

  /// The underlying provider/platform error. Shown behind a disclosure in the
  /// failure sheet — never as the headline.
  final String? details;

  const SocialAuthFailure({
    required this.provider,
    required this.message,
    this.details,
  });
}

class SocialAuthState {
  final SocialProvider? loading;
  final SocialAuthFailure? failure;

  const SocialAuthState({this.loading, this.failure});

  bool get isLoading => loading != null;

  SocialAuthState copyWith({
    SocialProvider? loading,
    SocialAuthFailure? failure,
    bool clearLoading = false,
    bool clearFailure = false,
  }) {
    return SocialAuthState(
      loading: clearLoading ? null : (loading ?? this.loading),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class SocialAuthNotifier extends Notifier<SocialAuthState> {
  @override
  SocialAuthState build() => const SocialAuthState();

  void clearFailure() => state = state.copyWith(clearFailure: true);

  Future<void> signInWithGoogle() =>
      _run(SocialProvider.google, SocialAuthService.signInWithGoogle);

  Future<void> signInWithApple() =>
      _run(SocialProvider.apple, SocialAuthService.signInWithApple);

  Future<void> _run(
    SocialProvider provider,
    Future<SocialAuthResult> Function() authenticate,
  ) async {
    if (state.isLoading) return;
    state = state.copyWith(loading: provider, clearFailure: true);

    final result = await authenticate();
    if (result.outcome == SocialAuthOutcome.cancelled) {
      state = state.copyWith(clearLoading: true);
      return;
    }
    if (result.outcome == SocialAuthOutcome.failed) {
      state = state.copyWith(
        clearLoading: true,
        failure: SocialAuthFailure(
          provider: provider,
          message: result.error ?? AppStrings.somethingWentWrong,
          details: result.details,
        ),
      );
      return;
    }

    try {
      final tokens = await ref
          .read(authRepositoryProvider)
          .socialAuth(firebaseToken: result.firebaseToken!);
      clearUserScopedDataRef(ref);
      await authStateService.logIn(tokens.accessToken, tokens.refreshToken);
      ref.read(userProfileProvider.notifier).fetch();
      Analytics.login(method: 'social');
      state = state.copyWith(clearLoading: true);
    } on AppException catch (e) {
      Log.e('Social auth exchange failed', error: e);
      await SocialAuthService.signOut();
      state = state.copyWith(
        clearLoading: true,
        failure: SocialAuthFailure(
          provider: provider,
          message: e.message,
          details: _describeExchangeFailure(e),
        ),
      );
    }
  }
}

/// The backend exchange failed, not the provider. Naming the status code and
/// exception type is what separates "backend rejected the token" from
/// "device never reached the backend".
String _describeExchangeFailure(AppException e) {
  final code = e is ApiException ? e.statusCode : null;
  return [
    'Backend token exchange failed',
    '${e.runtimeType}${code != null ? ' (HTTP $code)' : ''}',
    e.message,
  ].join('\n');
}

final socialAuthProvider =
    NotifierProvider<SocialAuthNotifier, SocialAuthState>(
  SocialAuthNotifier.new,
);

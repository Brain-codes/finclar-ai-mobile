import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/auth_state_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/session_reset.dart';
import '../../../core/services/social_auth_service.dart';
import 'auth_repository_provider.dart';
import 'user_profile_provider.dart';

enum SocialProvider { google, apple }

class SocialAuthState {
  final SocialProvider? loading;
  final String? snackbarError;

  const SocialAuthState({this.loading, this.snackbarError});

  bool get isLoading => loading != null;

  SocialAuthState copyWith({
    SocialProvider? loading,
    String? snackbarError,
    bool clearLoading = false,
    bool clearSnackbarError = false,
  }) {
    return SocialAuthState(
      loading: clearLoading ? null : (loading ?? this.loading),
      snackbarError:
          clearSnackbarError ? null : (snackbarError ?? this.snackbarError),
    );
  }
}

class SocialAuthNotifier extends Notifier<SocialAuthState> {
  @override
  SocialAuthState build() => const SocialAuthState();

  void clearSnackbarError() => state = state.copyWith(clearSnackbarError: true);

  Future<void> signInWithGoogle() =>
      _run(SocialProvider.google, SocialAuthService.signInWithGoogle);

  Future<void> signInWithApple() =>
      _run(SocialProvider.apple, SocialAuthService.signInWithApple);

  Future<void> _run(
    SocialProvider provider,
    Future<SocialAuthResult> Function() authenticate,
  ) async {
    if (state.isLoading) return;
    state = state.copyWith(loading: provider, clearSnackbarError: true);

    final result = await authenticate();
    if (result.outcome == SocialAuthOutcome.cancelled) {
      state = state.copyWith(clearLoading: true);
      return;
    }
    if (result.outcome == SocialAuthOutcome.failed) {
      state = state.copyWith(clearLoading: true, snackbarError: result.error);
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
      state = state.copyWith(clearLoading: true, snackbarError: e.message);
    }
  }
}

final socialAuthProvider =
    NotifierProvider<SocialAuthNotifier, SocialAuthState>(
  SocialAuthNotifier.new,
);

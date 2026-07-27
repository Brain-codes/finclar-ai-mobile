import 'package:flutter/foundation.dart';
import 'analytics_service.dart';
import 'logger_service.dart';
import 'storage_service.dart';

class AuthStateService extends ChangeNotifier {
  bool _initialized = false;
  bool _isOnboardingComplete = false;
  bool _isLoggedIn = false;
  bool _needsGoalsPrompt = false;

  bool get initialized => _initialized;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isLoggedIn => _isLoggedIn;
  bool get needsGoalsPrompt => _needsGoalsPrompt;

  AuthStateService() {
    _init();
  }

  Future<void> _init() async {
    try {
      _isOnboardingComplete = await StorageService.isOnboardingComplete();
      final token = await StorageService.getAccessToken();
      _isLoggedIn = token != null && token.isNotEmpty;

      if (_isLoggedIn) {
        final skipped = await StorageService.isGoalsSkipped();
        final completed = await StorageService.isGoalsCompleted();
        _needsGoalsPrompt = !skipped && !completed;
      }

      Log.d('AuthState init — onboarding:$_isOnboardingComplete loggedIn:$_isLoggedIn needsGoals:$_needsGoalsPrompt');
    } catch (e, st) {
      Log.e('AuthState init failed — defaulting to logged-out', error: e, stackTrace: st);
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    if (_isOnboardingComplete) return;
    await StorageService.setOnboardingComplete();
    _isOnboardingComplete = true;
    notifyListeners();
  }

  /// Call after successful login/verify-email.
  /// [isNewUser] = true skips local flag check and always prompts for goals.
  Future<void> logIn(
    String accessToken,
    String refreshToken, {
    bool isNewUser = false,
  }) async {
    await StorageService.saveTokens(access: accessToken, refresh: refreshToken);
    _isLoggedIn = true;

    if (isNewUser) {
      _needsGoalsPrompt = true;
    } else {
      final skipped = await StorageService.isGoalsSkipped();
      final completed = await StorageService.isGoalsCompleted();
      _needsGoalsPrompt = !skipped && !completed;
    }

    notifyListeners();
  }

  Future<void> goalsCompleted() async {
    await StorageService.setGoalsCompleted();
    _needsGoalsPrompt = false;
    notifyListeners();
  }

  Future<void> goalsSkipped() async {
    await StorageService.setGoalsSkipped();
    _needsGoalsPrompt = false;
    notifyListeners();
  }

  Future<void> logOut() async {
    await StorageService.clearTokens();
    await StorageService.clearCachedUser();
    await StorageService.clearBiometricPasscode();
    await StorageService.setBiometricEnabled(false);
    _isLoggedIn = false;
    _needsGoalsPrompt = false;
    Analytics.clearUser();
    notifyListeners();
  }
}

/// Module-level singleton shared by GoRouter and Riverpod.
final authStateService = AuthStateService();

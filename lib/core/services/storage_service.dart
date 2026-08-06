import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  StorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  static Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.tokenKey);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.tokenKey, value: access),
      _storage.write(key: AppConstants.refreshTokenKey, value: refresh),
    ]);
  }

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.tokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  static Future<String?> getLastEmail() =>
      _storage.read(key: AppConstants.lastEmailKey);

  static Future<void> saveLastEmail(String email) =>
      _storage.write(key: AppConstants.lastEmailKey, value: email);

  static Future<void> clearLastEmail() =>
      _storage.delete(key: AppConstants.lastEmailKey);

  static Future<bool> isOnboardingComplete() async {
    final value = await _storage.read(key: AppConstants.onboardingKey);
    return value == 'true';
  }

  static Future<void> setOnboardingComplete() =>
      _storage.write(key: AppConstants.onboardingKey, value: 'true');

  // ─── Home tour ──────────────────────────────────────────────────────────────
  // Deliberately a "pending" flag, not a "seen" flag: absence must mean *don't
  // show it*, so shipping this never ambushes an existing user.

  static Future<bool> isTourPending() async {
    final value = await _storage.read(key: AppConstants.tourPendingKey);
    return value == 'true';
  }

  static Future<void> setTourPending() =>
      _storage.write(key: AppConstants.tourPendingKey, value: 'true');

  static Future<void> clearTourPending() =>
      _storage.delete(key: AppConstants.tourPendingKey);

  // ─── Pending invite ─────────────────────────────────────────────────────────
  // An invite link opened while logged out. Replayed after the next successful
  // auth, then cleared so it can only ever fire once.

  static Future<String?> getPendingInvite() =>
      _storage.read(key: AppConstants.pendingInviteKey);

  static Future<void> savePendingInvite(String username) =>
      _storage.write(key: AppConstants.pendingInviteKey, value: username);

  static Future<void> clearPendingInvite() =>
      _storage.delete(key: AppConstants.pendingInviteKey);

  /// ISO week label of the last Friday challenge prompt, so it nudges once a
  /// week rather than on every app open.
  static Future<String?> getChallengePromptWeek() =>
      _storage.read(key: AppConstants.challengePromptWeekKey);

  static Future<void> setChallengePromptWeek(String week) =>
      _storage.write(key: AppConstants.challengePromptWeekKey, value: week);

  /// ISO week label of the last no-spend weekend prompt — one nudge per
  /// weekend, not one per app open across three days.
  static Future<String?> getWeekendPromptWeek() =>
      _storage.read(key: AppConstants.weekendPromptWeekKey);

  static Future<void> setWeekendPromptWeek(String week) =>
      _storage.write(key: AppConstants.weekendPromptWeekKey, value: week);

  /// `yyyy-MM-dd` the category budget nudge is next due. Rescheduled to a new
  /// random date each time it fires, so it never lands on a predictable day.
  static Future<String?> getCategoryPromptDate() =>
      _storage.read(key: AppConstants.categoryPromptDateKey);

  static Future<void> setCategoryPromptDate(String date) =>
      _storage.write(key: AppConstants.categoryPromptDateKey, value: date);

  /// `yyyy-MM-dd` of the last day the streak celebration was shown, so it fires
  /// once on the day's first expense rather than on every log.
  static Future<String?> getStreakModalDate() =>
      _storage.read(key: AppConstants.streakModalDateKey);

  static Future<void> setStreakModalDate(String date) =>
      _storage.write(key: AppConstants.streakModalDateKey, value: date);

  static Future<bool> isGoalsSkipped() async {
    final value = await _storage.read(key: AppConstants.goalsSkippedKey);
    return value == 'true';
  }

  static Future<void> setGoalsSkipped() =>
      _storage.write(key: AppConstants.goalsSkippedKey, value: 'true');

  static Future<bool> isGoalsCompleted() async {
    final value = await _storage.read(key: AppConstants.goalsCompletedKey);
    return value == 'true';
  }

  static Future<void> setGoalsCompleted() =>
      _storage.write(key: AppConstants.goalsCompletedKey, value: 'true');

  static Future<void> clearGoalsFlags() async {
    await Future.wait([
      _storage.delete(key: AppConstants.goalsSkippedKey),
      _storage.delete(key: AppConstants.goalsCompletedKey),
    ]);
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: AppConstants.biometricEnabledKey);
    return value == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(
        key: AppConstants.biometricEnabledKey,
        value: enabled ? 'true' : 'false',
      );

  static Future<String?> getCachedUser() =>
      _storage.read(key: AppConstants.userKey);

  static Future<void> saveCachedUser(String json) =>
      _storage.write(key: AppConstants.userKey, value: json);

  static Future<void> clearCachedUser() =>
      _storage.delete(key: AppConstants.userKey);

  static Future<String?> getBiometricPasscode() =>
      _storage.read(key: AppConstants.biometricPasscodeKey);

  static Future<void> saveBiometricPasscode(String passcode) =>
      _storage.write(key: AppConstants.biometricPasscodeKey, value: passcode);

  static Future<void> clearBiometricPasscode() =>
      _storage.delete(key: AppConstants.biometricPasscodeKey);
}

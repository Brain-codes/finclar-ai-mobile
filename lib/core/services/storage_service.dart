import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  StorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
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
}

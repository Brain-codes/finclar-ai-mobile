abstract class AppConstants {
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_complete';
  static const String incomeSetupKey = 'income_setup_complete';
  static const String aiSetupKey = 'ai_setup_complete';
  static const String currencyCodeKey = 'currency_code';
  static const String categoriesKey = 'categories_cache';

  // API
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Pagination
  static const int defaultPageSize = 20;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animBase = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);

  // OTP
  static const int otpLength = 6;
  static const int resendCooldown = 60; // seconds

  // Passcode
  static const int passcodeLength = 6;
}

abstract class AppConstants {
  // Group membership limits (includes the owner)
  static const int maxGroupMembers = 10;

  // The gamification design gallery is internal-only. Off unless a build
  // passes --dart-define=SHOW_GAMIFY_GALLERY=true, so release builds hide it.
  // static const bool showGamifyGallery =
  //     bool.fromEnvironment('SHOW_GAMIFY_GALLERY');
    static const bool showGamifyGallery = true;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_complete';
  static const String lastEmailKey = 'last_login_email';
  static const String incomeSetupKey = 'income_setup_complete';
  static const String aiSetupKey = 'ai_setup_complete';
  static const String currencyCodeKey = 'currency_code';
  static const String categoriesKey = 'categories_cache';
  static const String goalsSkippedKey = 'goals_skipped';
  static const String goalsCompletedKey = 'goals_completed';
  static const String challengePromptWeekKey = 'challenge_prompt_week';
  static const String weekendPromptWeekKey = 'weekend_prompt_week';
  static const String categoryPromptDateKey = 'category_prompt_date';
  static const String streakModalDateKey = 'streak_modal_date';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String biometricPasscodeKey = 'biometric_passcode';
  static const String tourPendingKey = 'home_tour_pending';
  static const String pendingInviteKey = 'pending_invite_username';

  // Invites / deep links
  static const String appScheme = 'finclar';
  static const String inviteBaseUrl = 'https://finclarai.com/invite';

  // API
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // AI receipt scanning (OpenAI). Key supplied at build time via
  //   --dart-define=OPENAI_API_KEY=sk-...   (keeps it out of source/git).
  // NOTE: a key compiled into a mobile binary is still extractable — move this
  // server-side before production.
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String openAiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );
  static const String openAiBaseUrl = 'https://api.openai.com/v1';

  // Mono Connect public key — pass at build time:
  //   --dart-define=MONO_PUBLIC_KEY=test_pk_...
  // A public key in a mobile binary is fine to ship (it only opens the widget;
  // the returned code is exchanged server-side).
  static const String monoPublicKey = String.fromEnvironment('MONO_PUBLIC_KEY');

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

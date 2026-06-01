/// All backend endpoint paths.
///
/// Keep this file in sync with docs/API.md.
/// Never write a URL string outside this file.
abstract class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://finclar-ai.onrender.com/api/v1',
  );

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String register        = '/auth/register';
  static const String verifyEmail     = '/auth/verify-email';
  static const String resendOtp       = '/auth/resend-otp';
  static const String login           = '/auth/login';
  static const String refreshToken    = '/auth/refresh';
  static const String logout          = '/auth/logout';
  static const String logoutAll       = '/auth/logout-all';
  static const String forgotPasscode  = '/auth/forgot-passcode';
  static const String resetPasscode   = '/auth/reset-passcode';
  static const String onboardingGoals = '/auth/onboarding/goals';

  // ─── User ─────────────────────────────────────────────────────────────────
  static const String checkUsername = '/user/check-username';
  static const String me            = '/user/me';

  // ─── Income ───────────────────────────────────────────────────────────────
  static const String incomeSources = '/income/sources';
  static const String income        = '/income';

  // ─── Planned — not yet live on backend (see docs/API.md) ──────────────────
  static const String expenses         = '/expenses';
  static String expense(String id)     => '/expenses/$id';
  static const String expenseOcr       = '/expenses/ocr';
  static const String budgets          = '/budgets';
  static String budget(String id)      => '/budgets/$id';
  static const String groups           = '/groups';
  static String group(String id)       => '/groups/$id';
  static String groupMembers(String id)=> '/groups/$id/members';
  static const String transactions     = '/transactions';
  static String transaction(String id) => '/transactions/$id';
  static const String categories       = '/categories';
  static const String chat             = '/ai/chat';
  static const String chatHistory      = '/ai/chat/history';
  static const String subscription     = '/subscription';
  static const String subscriptionPlans= '/subscription/plans';
}

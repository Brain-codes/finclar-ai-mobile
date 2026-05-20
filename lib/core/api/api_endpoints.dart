abstract class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.finclar.com/v1',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyPhone = '/auth/verify-phone';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPasscode = '/auth/forgot-passcode';
  static const String resetPasscode = '/auth/reset-passcode';
  static const String refreshToken = '/auth/refresh';

  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // Income
  static const String income = '/income';
  static const String incomeSetup = '/income/setup';
  static const String aiIncomeSetup = '/income/ai-setup';

  // Expenses
  static const String expenses = '/expenses';
  static String expense(String id) => '/expenses/$id';
  static const String expenseOcr = '/expenses/ocr';
  static const String bankIntegration = '/expenses/bank-integration';

  // Budget
  static const String budgets = '/budgets';
  static String budget(String id) => '/budgets/$id';

  // Group
  static const String groups = '/groups';
  static String group(String id) => '/groups/$id';
  static String groupMembers(String id) => '/groups/$id/members';
  static String groupInvite(String id) => '/groups/$id/invite';

  // Transactions
  static const String transactions = '/transactions';
  static String transaction(String id) => '/transactions/$id';

  // AI / Chat
  static const String chat = '/ai/chat';
  static const String chatHistory = '/ai/chat/history';

  // Subscription
  static const String subscription = '/subscription';
  static const String subscriptionPlans = '/subscription/plans';
}

/// All backend endpoint paths.
///
/// Keep this file in sync with docs/API.md.
/// Never write a URL string outside this file.
abstract class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.finclarai.com/api/v1',
  );

  /// WebSocket origin derived from [baseUrl] (http→ws, https→wss).
  static String get wsBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'^http'), 'ws');

  /// Group chat socket. Pass the access token as [token] (WS upgrade can't send
  /// an Authorization header, so the backend reads it from the query string).
  static String groupChatSocket(String groupId, String token) =>
      '$wsBaseUrl/groups/$groupId/ws?token=$token';

  // ─── Health ───────────────────────────────────────────────────────────────
  static const String health = '/health';

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
  static const String socialAuth      = '/auth/social';

  // ─── User ─────────────────────────────────────────────────────────────────
  static const String checkUsername = '/user/check-username';

  /// `GET` for the profile, `PATCH` to update it (`UpdateUserDto`).
  static const String me            = '/user/me';

  // ─── Income ───────────────────────────────────────────────────────────────
  static const String incomeSources    = '/income/sources';
  static const String income           = '/income';
  static const String incomeCalculate  = '/income/calculate';
  static String incomeById(String id)  => '/income/$id';

  // ─── Goals & Categories ───────────────────────────────────────────────────
  static const String goals      = '/goals';
  static const String categories = '/categories';

  // ─── Expenses ─────────────────────────────────────────────────────────────
  static const String expenses       = '/expenses';
  static String expense(String id)   => '/expenses/$id';
  static const String expenseReceipt = '/expenses/receipt';
  static const String expenseSummary = '/expenses/summary';
  static const String expenseStreak  = '/expenses/streak';
  // Backend QA helper — only called from the dev-flagged tools sheet.
  static String expenseStreakSimulate(int days) =>
      '/expenses/streak/dev/simulate?days=$days';

  // ─── Insights ─────────────────────────────────────────────────────────────
  static const String homeInsight = '/insights/home';

  // ─── Wrapped (year in review) ─────────────────────────────────────────────
  static const String wrapped = '/wrapped';

  // ─── Clara AI chat ────────────────────────────────────────────────────────
  static const String claraChat     = '/clara/chat';
  static const String claraMessages = '/clara/messages';

  // ─── Banks ────────────────────────────────────────────────────────────────
  static const String banks               = '/banks';
  static const String banksAvailable      = '/banks/available';
  static const String bankLink            = '/banks/link';
  static String bankSync(String id)       => '/banks/$id/sync';
  static String bankBalance(String id)    => '/banks/$id/balance';
  static String bank(String id)           => '/banks/$id';

  // ─── Budgets ──────────────────────────────────────────────────────────────
  static const String budgets       = '/budgets';
  static String budget(String id)   => '/budgets/$id';
  static String budgetAllocations(String budgetId) =>
      '/budgets/$budgetId/allocations';
  static String budgetAllocation(String budgetId, String categoryId) =>
      '/budgets/$budgetId/allocations/$categoryId';
  static String budgetInsight(String id) => '/budgets/$id/insight';

  // ─── Friends ──────────────────────────────────────────────────────────────
  static const String friendsSearch  = '/friends/search';
  static const String friends        = '/friends';
  static const String friendInvite   = '/friends/invite';
  static const String friendInvites  = '/friends/invites';
  static String friendInviteAccept(String inviteId) =>
      '/friends/invites/$inviteId/accept';
  static String friendInviteDecline(String inviteId) =>
      '/friends/invites/$inviteId/decline';
  static String friend(String friendshipId) => '/friends/$friendshipId';

  // ─── Groups (group savings) ────────────────────────────────────────────────
  static const String groups             = '/groups';
  static String group(String id)         => '/groups/$id';
  static String groupLeave(String id)    => '/groups/$id/leave';
  static String groupInvite(String id)   => '/groups/$id/invite';
  static String groupShare(String id)    => '/groups/$id/share';

  static String groupMembers(String id) => '/groups/$id/members';
  static String groupMember(String groupId, String memberId) =>
      '/groups/$groupId/members/$memberId';
  static String groupSavings(String id)  => '/groups/$id/savings';
  static String groupMessages(String id) => '/groups/$id/messages';
  static String groupMessageAttachment(String id) =>
      '/groups/$id/messages/attachment';

  // ─── Subscriptions ────────────────────────────────────────────────────────
  static const String subscriptionPlans   = '/subscriptions/plans';
  static const String mySubscription      = '/subscriptions/me';
  static const String subscriptionVerify  = '/subscriptions/checkout/verify';
  static const String subscriptionCancel  = '/subscriptions/cancel';
  static const String subscriptionResume  = '/subscriptions/resume';

  // ─── Savings Challenges ───────────────────────────────────────────────────
  static const String challenges           = '/challenges';
  static String challenge(String id)       => '/challenges/$id';
  static String challengeEntries(String id) => '/challenges/$id/entries';
  static const String challengeBadgeCatalog = '/challenges/badges/catalog';
  static const String challengeBadgesMine   = '/challenges/badges/mine';
  // Backend QA helpers — only called from the dev-flagged tools sheet.
  static String challengeSimulateStreak(String id, int weeks) =>
      '/challenges/$id/dev/simulate-streak?weeks=$weeks';
  static String challengeTestReminder(String id) =>
      '/challenges/$id/dev/send-test-reminder';

  // ─── Push Notifications (device tokens) ──────────────────────────────────
  static const String deviceTokens = '/notifications/device-tokens';
  static String deviceToken(String id) => '/notifications/device-tokens/$id';
  static const String testPush = '/notifications/test-push';
}

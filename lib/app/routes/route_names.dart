abstract class RouteNames {
  // Startup (auth-gate loading screen)
  static const String startup = '/startup';

  // Splash
  static const String splash = '/';

  // Auth
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String verifyEmail = '/verify-email';
  static const String verifyPhone = '/verify-phone';
  static const String forgotPasscode = '/forgot-passcode';
  static const String resetPasscode = '/reset-passcode';
  static const String setPasscode = '/set-passcode';
  static const String preference = '/preference';

  // Shell (bottom nav)
  static const String shell = '/app';

  // Home
  static const String home = '/app/home';
  static const String incomeSetup = '/app/home/income-setup';
  static const String aiSetup = '/app/home/ai-setup';
  static const String spending = '/app/home/spending';
  static const String notifications = '/app/home/notifications';

  // Expenses
  static const String expenses = '/app/expenses';
  static const String expenseDetail = '/app/expenses/detail';
  static const String addExpense = '/app/expenses/add';
  static const String addExpenseOcr = '/app/expenses/add/ocr';
  static const String scannedExpense = '/app/expenses/scanned';
  static const String bankIntegration = '/app/expenses/bank';
  static const String bankLinkingSuccess = '/app/expenses/bank/success';

  // Budget
  static const String budget = '/app/budget';
  static const String createBudget = '/app/budget/create';

  // Group
  static const String group = '/app/group';
  static const String createGroup = '/app/group/create';
  static const String groupDetail = '/group/detail';
  static const String groupFriends = '/group/friends';
  static const String groupChat = '/group/chat';
  static const String addFriend = '/app/group/add-friend';
  static const String friends = '/friends';

  // Clara AI chat
  static const String clara = '/clara';

  // Settings
  static const String settings                = '/settings';
  static const String subscription            = '/settings/subscription';
  static const String settingsChangePasscode  = '/settings/change-passcode';
  static const String settingsContactUs       = '/settings/contact-us';
  static const String settingsFaq             = '/settings/faq';
  static const String settingsMessage         = '/settings/message';
  static const String settingsAccountDeletion = '/settings/delete-account';
  static const String settingsMyAccounts      = '/settings/my-accounts';
  static const String settingsAvatar          = '/settings/avatar';

  // Gamification
  static const String gamificationPreview = '/settings/gamify';
  static const String badges              = '/settings/badges';
  static const String challenges          = '/settings/challenges';
  static const String challengeDetail     = '/settings/challenges/detail';
  static const String wrapped             = '/settings/wrapped';

  // Legal
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
}

abstract class RouteNames {
  // Splash
  static const String splash = '/';

  // Auth
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String verifyEmail = '/verify-email';
  static const String verifyPhone = '/verify-phone';
  static const String forgotPasscode = '/forgot-passcode';
  static const String resetPasscode = '/reset-passcode';

  // Shell (bottom nav)
  static const String shell = '/app';

  // Home
  static const String home = '/app/home';
  static const String incomeSetup = '/app/home/income-setup';
  static const String aiSetup = '/app/home/ai-setup';

  // Expenses
  static const String expenses = '/app/expenses';
  static const String addExpense = '/app/expenses/add';
  static const String addExpenseOcr = '/app/expenses/add/ocr';
  static const String bankIntegration = '/app/expenses/bank';

  // Budget
  static const String budget = '/app/budget';
  static const String createBudget = '/app/budget/create';

  // Group
  static const String group = '/app/group';
  static const String createGroup = '/app/group/create';
  static const String groupDetail = '/app/group/:id';
  static const String addFriend = '/app/group/add-friend';

  // Settings
  static const String settings = '/settings';
  static const String subscription = '/settings/subscription';
}

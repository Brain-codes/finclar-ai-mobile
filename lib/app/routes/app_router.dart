import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/verify_screen.dart';
import '../../features/auth/presentation/screens/passcode_screen.dart';
import '../../features/auth/presentation/screens/preference_screen.dart';
import '../../features/auth/presentation/screens/forgot_passcode_screen.dart';
import '../../features/auth/presentation/screens/reset_passcode_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/income_setup_screen.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/expenses/presentation/screens/expense_preview_screen.dart';
import '../../features/expenses/presentation/screens/spending_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/budget/presentation/screens/create_budget_screen.dart';
import '../../features/group/presentation/screens/group_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/change_passcode_screen.dart';
import '../../features/settings/presentation/screens/contact_us_screen.dart';
import '../../features/settings/presentation/screens/faq_screen.dart';
import '../../features/settings/presentation/screens/message_screen.dart';
import '../../features/settings/presentation/screens/account_deletion_screen.dart';
import '../../features/settings/presentation/screens/my_accounts_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/auth/presentation/screens/terms_of_service_screen.dart';
import '../../features/auth/presentation/screens/privacy_policy_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'route_names.dart';

// MaterialPage maps to CupertinoPageRoute on iOS → native slide transition +
// swipe-back gesture. On Android it maps to MaterialPageRoute → predictive
// back works via android:enableOnBackInvokedCallback in the manifest.
Page<T> _page<T>(GoRouterState state, Widget child) {
  return MaterialPage<T>(key: state.pageKey, child: child);
}

final appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth
    GoRoute(
      path: RouteNames.login,
      pageBuilder: (context, state) => _page(state, const LoginScreen()),
    ),
    GoRoute(
      path: RouteNames.signUp,
      pageBuilder: (context, state) => _page(state, const SignUpScreen()),
    ),
    GoRoute(
      path: RouteNames.verifyEmail,
      pageBuilder: (context, state) {
        final email = state.extra as String? ?? '';
        return _page(state, VerifyScreen(email: email));
      },
    ),
    GoRoute(
      path: RouteNames.setPasscode,
      pageBuilder: (context, state) => _page(state, const PasscodeScreen()),
    ),
    GoRoute(
      path: RouteNames.preference,
      pageBuilder: (context, state) => _page(state, const PreferenceScreen()),
    ),
    GoRoute(
      path: RouteNames.forgotPasscode,
      pageBuilder: (context, state) => _page(state, const ForgotPasscodeScreen()),
    ),
    GoRoute(
      path: RouteNames.resetPasscode,
      pageBuilder: (context, state) => _page(state, const ResetPasscodeScreen()),
    ),

    // Main shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: RouteNames.expenses,
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: RouteNames.budget,
          builder: (context, state) => const BudgetScreen(),
        ),
        GoRoute(
          path: RouteNames.group,
          builder: (context, state) => const GroupScreen(),
        ),
      ],
    ),

    // Expense sub-routes (outside shell — no bottom nav)
    GoRoute(
      path: RouteNames.expenseDetail,
      pageBuilder: (context, state) {
        final expense = state.extra as ExpenseModel;
        return _page(state, ExpensePreviewScreen(expense: expense));
      },
    ),

    // Budget sub-routes (outside shell — no bottom nav)
    GoRoute(
      path: RouteNames.createBudget,
      pageBuilder: (context, state) {
        final title = state.extra as String? ?? 'Create budget';
        return _page(state, CreateBudgetScreen(title: title));
      },
    ),

    // Home sub-routes (outside shell — no bottom nav)
    GoRoute(
      path: RouteNames.incomeSetup,
      pageBuilder: (context, state) => _page(state, const IncomeSetupScreen()),
    ),
    GoRoute(
      path: RouteNames.spending,
      pageBuilder: (context, state) => _page(state, const SpendingScreen()),
    ),

    // Settings (outside shell)
    GoRoute(
      path: RouteNames.settings,
      pageBuilder: (context, state) => _page(state, const SettingsScreen()),
    ),
    GoRoute(
      path: RouteNames.subscription,
      pageBuilder: (context, state) => _page(state, const SubscriptionScreen()),
    ),
    GoRoute(
      path: RouteNames.settingsChangePasscode,
      pageBuilder: (context, state) => _page(state, const ChangePasscodeScreen()),
    ),
    GoRoute(
      path: RouteNames.settingsContactUs,
      pageBuilder: (context, state) => _page(state, const ContactUsScreen()),
    ),
    GoRoute(
      path: RouteNames.settingsFaq,
      pageBuilder: (context, state) => _page(state, const FaqScreen()),
    ),
    GoRoute(
      path: RouteNames.settingsMessage,
      pageBuilder: (context, state) => _page(state, const MessageScreen()),
    ),
    GoRoute(
      path: RouteNames.settingsAccountDeletion,
      pageBuilder: (context, state) => _page(state, const AccountDeletionScreen()),
    ),
    GoRoute(
      path: RouteNames.settingsMyAccounts,
      pageBuilder: (context, state) => _page(state, const MyAccountsScreen()),
    ),

    // Legal
    GoRoute(
      path: RouteNames.termsOfService,
      pageBuilder: (context, state) => _page(state, const TermsOfServiceScreen()),
    ),
    GoRoute(
      path: RouteNames.privacyPolicy,
      pageBuilder: (context, state) => _page(state, const PrivacyPolicyScreen()),
    ),
  ],
);

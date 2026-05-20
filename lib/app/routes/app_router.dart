import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/verify_screen.dart';
import '../../features/auth/presentation/screens/forgot_passcode_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/group/presentation/screens/group_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: RouteNames.verifyEmail,
      builder: (context, state) => const VerifyScreen(type: VerifyType.email),
    ),
    GoRoute(
      path: RouteNames.verifyPhone,
      builder: (context, state) => const VerifyScreen(type: VerifyType.phone),
    ),
    GoRoute(
      path: RouteNames.forgotPasscode,
      builder: (context, state) => const ForgotPasscodeScreen(),
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

    // Settings (outside shell)
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: RouteNames.subscription,
      builder: (context, state) => const SubscriptionScreen(),
    ),
  ],
);

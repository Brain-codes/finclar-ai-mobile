import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_overlay.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_text_link.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../providers/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passcodeController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();
    ref.read(loginProvider.notifier).continueWithEmail(_emailController.text);
  }

  Future<void> _onPasscodeCompleted(String code) async {
    await ref.read(loginProvider.notifier).submitPasscode(code);
    if (mounted) _passcodeController.clear();
  }

  void _onBack() {
    final phase = ref.read(loginProvider).phase;
    if (phase == LoginPhase.passcode && !ref.read(loginProvider).isReturningUser) {
      ref.read(loginProvider.notifier).backToEmail();
    } else if (context.canPop()) {
      context.pop();
    }
  }

  void _showEmailNotVerifiedSheet(String email) {
    showAppSheet<void>(
      context,
      title: 'Email not verified',
      children: [
        _EmailNotVerifiedSheetContent(
          email: email,
          onResend: () async {
            Navigator.of(context, rootNavigator: true).pop();
            final success =
                await ref.read(loginProvider.notifier).resendVerification();
            if (success && mounted) {
              context.push(RouteNames.verifyEmail, extra: email);
            }
          },
        ),
      ],
    );
    ref.read(loginProvider.notifier).clearEmailNotVerified();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);

    ref.listen(loginProvider, (prev, next) {
      if (next.snackbarError != null && next.snackbarError != prev?.snackbarError) {
        AppSnackbar.error(context, next.snackbarError!);
        ref.read(loginProvider.notifier).clearSnackbarError();
      }
      if (next.emailNotVerified && !(prev?.emailNotVerified ?? false)) {
        _showEmailNotVerifiedSheet(next.email);
      }
    });

    if (!state.initialized) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Top bar ───────────────────────────────────────────────
                  _LoginTopBar(
                    phase: state.phase,
                    isReturningUser: state.isReturningUser,
                    onBack: _onBack,
                    onNotMyAccount: () =>
                        ref.read(loginProvider.notifier).clearSavedEmail(),
                  ),

                  // ── Content card ──────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.scaffoldColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: state.phase == LoginPhase.email
                            ? _EmailPhase(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                state: state,
                                onContinue: _onContinue,
                                onSignUpTap: () =>
                                    context.push(RouteNames.signUp),
                                onEmailChanged: () => ref
                                    .read(loginProvider.notifier)
                                    .clearEmailError(),
                              )
                            : _PasscodePhase(
                                controller: _passcodeController,
                                email: state.email,
                                onCompleted: _onPasscodeCompleted,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            if (state.isLoading) const AppLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _LoginTopBar extends StatelessWidget {
  final LoginPhase phase;
  final bool isReturningUser;
  final VoidCallback onBack;
  final VoidCallback onNotMyAccount;

  const _LoginTopBar({
    required this.phase,
    required this.isReturningUser,
    required this.onBack,
    required this.onNotMyAccount,
  });

  @override
  Widget build(BuildContext context) {
    // Returning users on the passcode phase see "Not my account" on the right.
    if (isReturningUser && phase == LoginPhase.passcode) {
      return SizedBox(
        height: 48,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.screenPadding),
            child: GestureDetector(
              onTap: onNotMyAccount,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.notMyAccount,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    AppIcons.chevronRight,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // First-time user on email phase — no back.
    // First-time user on passcode phase — back to email.
    final showBack = phase == LoginPhase.passcode;
    return AppTopBar(onBack: onBack, showBack: showBack);
  }
}

// ─── Phase 1 — email ─────────────────────────────────────────────────────────

class _EmailPhase extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final LoginState state;
  final VoidCallback onContinue;
  final VoidCallback onSignUpTap;
  final VoidCallback onEmailChanged;

  const _EmailPhase({
    required this.controller,
    required this.focusNode,
    required this.state,
    required this.onContinue,
    required this.onSignUpTap,
    required this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scrollable content — header + email field
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const AppScreenHeader(title: AppStrings.loginTitle),
                const SizedBox(height: AppSpacing.xxl),
                AppTextField(
                  label: AppStrings.emailAddress,
                  hint: AppStrings.enterEmailAddress,
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  errorText: state.emailError,
                  onEditingComplete: onContinue,
                  onChanged: (_) => onEmailChanged(),
                ),
              ],
            ),
          ),
        ),

        // Fixed bottom — button + sign-up link
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.base,
            AppSpacing.screenPadding,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              AppButton(
                label: AppStrings.continueText,
                onTap: onContinue,
                isLoading: state.isLoading,
              ),
              const SizedBox(height: AppSpacing.base),
              AppTextLink(
                prompt: AppStrings.dontHaveAccount,
                actionLabel: AppStrings.signUp,
                onTap: onSignUpTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Phase 2 — passcode ───────────────────────────────────────────────────────

class _PasscodePhase extends StatelessWidget {
  final TextEditingController controller;
  final String email;
  final Future<void> Function(String) onCompleted;

  const _PasscodePhase({
    required this.controller,
    required this.email,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          const _UserAvatar(),
          const SizedBox(height: AppSpacing.lg),
          AppScreenHeader(
            title: AppStrings.welcomeBack,
            subtitle: email,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppOtpField(
            controller: controller,
            autofocus: true,
            obscureText: true,
            onCompleted: onCompleted,
          ),
          const SizedBox(height: AppSpacing.base),
          Center(
            child: GestureDetector(
              onTap: () => context.push(RouteNames.forgotPasscode),
              child: Text(
                AppStrings.forgotPasscode,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ─── 403 bottom sheet content ─────────────────────────────────────────────────

class _EmailNotVerifiedSheetContent extends StatelessWidget {
  final String email;
  final VoidCallback onResend;

  const _EmailNotVerifiedSheetContent({
    required this.email,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              AppIcons.email,
              color: AppColors.warning,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Your email address hasn\'t been verified yet.',
          style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          email,
          style: AppTypography.labelMedium.copyWith(color: context.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: 'Resend verification code',
          onTap: onResend,
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ─── User avatar ─────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.categoryFoodBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFC099), width: 1.5),
          ),
          child: const Icon(AppIcons.userFill, color: AppColors.white, size: 18),
        ),
      ),
    );
  }
}

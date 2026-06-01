import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/svg/app_svg.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_text_link.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../providers/sign_up_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailFocus = FocusNode();
  final _usernameFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _emailFocus.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();
    final success = ref
        .read(signUpProvider.notifier)
        .submit(_emailController.text, _usernameController.text);
    if (success) {
      context.push(RouteNames.setPasscode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(signUpProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────────────
                AppTopBar(
                  onBack: () => context.pop(),
                  stepLabel: AppStrings.step1of3,
                ),

                // ── Scrollable body ────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.scaffoldColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.screenPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: AppSpacing.lg),

                                  AppScreenHeader(
                                    title: AppStrings.createAccountTitle,
                                  ),
                                  const SizedBox(height: AppSpacing.xxl),

                                  // Email field
                                  AppTextField(
                                    label: AppStrings.emailAddress,
                                    hint: AppStrings.enterEmailAddress,
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () => FocusScope.of(
                                      context,
                                    ).requestFocus(_usernameFocus),
                                    errorText: formState.emailError,
                                    onChanged: (_) => ref
                                        .read(signUpProvider.notifier)
                                        .clearEmailError(),
                                  ),
                                  const SizedBox(height: AppSpacing.base),

                                  // Username field
                                  AppTextField(
                                    label: AppStrings.username,
                                    hint: 'Enter username',
                                    controller: _usernameController,
                                    focusNode: _usernameFocus,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: _onContinue,
                                    errorText: formState.usernameError,
                                    onChanged: (v) => ref
                                        .read(signUpProvider.notifier)
                                        .onUsernameChanged(v),
                                    suffix: _UsernameSuffix(
                                      status: formState.usernameStatus,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxl),

                                  // Continue button
                                  AppButton(
                                    label: AppStrings.continueText,
                                    onTap: _onContinue,
                                    isLoading: formState.isLoading,
                                  ),
                                  const SizedBox(height: AppSpacing.base),

                                  // Have an account? Login
                                  Center(
                                    child: AppTextLink(
                                      prompt: AppStrings.haveAnAccount,
                                      actionLabel: AppStrings.login,
                                      onTap: () =>
                                          context.push(RouteNames.login),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Or divider
                                  _OrDivider(),
                                  const SizedBox(height: AppSpacing.base),

                                  // Social buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          label: AppStrings.google,
                                          onTap: () {},
                                          variant: AppButtonVariant.secondary,
                                          svgIcon: AppSvg.google,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: AppButton(
                                          label: AppStrings.apple,
                                          onTap: () {},
                                          variant: AppButtonVariant.secondary,
                                          svgIcon: AppSvg.apple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xxl),
                                ],
                              ),
                            ),
                          ),
                          _TermsFooter(),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Or divider ───────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: context.borderColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            AppStrings.orDivider,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: context.borderColor)),
      ],
    );
  }
}

// ─── Username suffix icon ─────────────────────────────────────────────────────

class _UsernameSuffix extends StatelessWidget {
  const _UsernameSuffix({required this.status});

  final UsernameStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      UsernameStatus.checking => const CupertinoActivityIndicator(radius: 9),
      UsernameStatus.available => Icon(
          AppIcons.success,
          color: AppColors.success,
          size: 20,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─── Terms footer ─────────────────────────────────────────────────────────────

class _TermsFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: context.textSecondary,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 1.4,
    );
    final link = base?.copyWith(
      color: context.textPrimary,
      decoration: TextDecoration.underline,
      decorationColor: context.textPrimary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: base,
          children: [
            const TextSpan(text: 'By creating an account, you agree to the '),
            TextSpan(
              text: 'Terms of Service',
              style: link,
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push(RouteNames.termsOfService),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: link,
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push(RouteNames.privacyPolicy),
            ),
          ],
        ),
      ),
    );
  }
}

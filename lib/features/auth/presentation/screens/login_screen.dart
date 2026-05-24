import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../providers/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? userName;
  final String? userEmail;

  const LoginScreen({super.key, this.userName, this.userEmail});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onCompleted(String code) async {
    final success = await ref.read(loginProvider.notifier).login(code);
    if (success && mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);

    ref.listen(loginProvider, (prev, next) {
      if (prev != null && !prev.hasError && next.hasError) {
        _controller.clear();
      }
    });

    final name = widget.userName ?? 'there';
    final email = widget.userEmail ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
            SafeArea(
              child: Column(
                children: [
                  _NotMyAccountBar(
                    onTap: () => context.push(RouteNames.signUp),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppSpacing.xxxl),
                          const _UserAvatar(),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            '${AppStrings.welcomeBack}$name',
                            style: AppTypography.headingSmall,
                            textAlign: TextAlign.center,
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              email,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          AppOtpField(
                            controller: _controller,
                            autofocus: true,
                            obscureText: true,
                            hasError: state.hasError,
                            errorText: state.errorText,
                            onChanged: (_) =>
                                ref.read(loginProvider.notifier).clearError(),
                            onCompleted: _onCompleted,
                          ),
                          const SizedBox(height: AppSpacing.base),
                          GestureDetector(
                            onTap: () => context.push(RouteNames.forgotPasscode),
                            child: Text(
                              AppStrings.forgotPasscode,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Not my account top bar ──────────────────────────────────────────────────

class _NotMyAccountBar extends StatelessWidget {
  final VoidCallback onTap;
  const _NotMyAccountBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.screenPadding),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.notMyAccount,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
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
}

// ─── User avatar placeholder ─────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.categoryFoodBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFC099), width: 1.5),
          ),
          child: const Icon(AppIcons.userFill, color: AppColors.white, size: 20),
        ),
      ),
    );
  }
}

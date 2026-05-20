import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../providers/verify_email_provider.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onCompleted(String code) async {
    final success = await ref.read(verifyEmailProvider.notifier).verify(code);
    if (success && mounted) {
      context.push(RouteNames.setPasscode);
    }
  }

  Future<void> _onContinue() async {
    final code = _controller.text;
    if (code.length < 6) return;
    await _onCompleted(code);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyEmailProvider);

    ref.listen(verifyEmailProvider, (prev, next) {
      if (!prev!.hasError && next.hasError) {
        _controller.clear();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                AppTopBar(
                  onBack: () => context.pop(),
                  stepLabel: AppStrings.step2of3,
                ),
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
                          title: AppStrings.verificationTitle,
                          subtitle: AppStrings.verificationSubtitle,
                          highlightedText: widget.email,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppOtpField(
                          controller: _controller,
                          hasError: state.hasError,
                          errorText: state.errorText,
                          onChanged: (_) => ref
                              .read(verifyEmailProvider.notifier)
                              .clearError(),
                          onCompleted: _onCompleted,
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Center(
                          child: state.canResend
                              ? _ResendLink(
                                  onTap: () {
                                    _controller.clear();
                                    ref
                                        .read(verifyEmailProvider.notifier)
                                        .resend();
                                  },
                                )
                              : _ResendCountdown(seconds: state.resendSeconds),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.base,
                    AppSpacing.screenPadding,
                    AppSpacing.xl,
                  ),
                  child: AppButton(
                    label: AppStrings.continueText,
                    onTap: state.isLoading ? null : _onContinue,
                    isLoading: state.isLoading,
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

// ─── Resend link ──────────────────────────────────────────────────────────────

class _ResendLink extends StatelessWidget {
  final VoidCallback onTap;
  const _ResendLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.didntReceiveCode,
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            AppStrings.resendCode,
            style: AppTypography.link.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// ─── Resend countdown ─────────────────────────────────────────────────────────

class _ResendCountdown extends StatelessWidget {
  final int seconds;
  const _ResendCountdown({required this.seconds});

  String get _formatted {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${AppStrings.resendIn}$_formatted',
      style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
    );
  }
}

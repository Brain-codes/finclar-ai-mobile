import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_loading_overlay.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/services/auth_state_service.dart';
import '../../providers/reset_passcode_provider.dart';

class ResetPasscodeScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasscodeScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasscodeScreen> createState() => _ResetPasscodeScreenState();
}

class _ResetPasscodeScreenState extends ConsumerState<ResetPasscodeScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(resetPasscodeProvider.notifier).sendOtp(widget.email));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBackTap() {
    final phase = ref.read(resetPasscodeProvider).phase;
    _controller.clear();
    if (phase == ResetPasscodePhase.confirm) {
      ref.read(resetPasscodeProvider.notifier).backToCreate();
    } else if (phase == ResetPasscodePhase.create) {
      ref.read(resetPasscodeProvider.notifier).backToOtp();
    } else {
      if (context.canPop()) context.pop();
    }
  }

  Future<void> _onCompleted(String code) async {
    final notifier = ref.read(resetPasscodeProvider.notifier);
    final phase = ref.read(resetPasscodeProvider).phase;
    _controller.clear();

    if (phase == ResetPasscodePhase.otp) {
      notifier.onOtpEntered(code);
    } else if (phase == ResetPasscodePhase.create) {
      notifier.onPasscodeCreated(code);
    } else {
      final success = await notifier.onPasscodeConfirmed(widget.email, code);
      if (success && mounted) {
        await authStateService.logOut();
        if (mounted) {
          AppSnackbar.success(context, 'Passcode changed successfully');
          context.go(RouteNames.login);
        }
      } else if (mounted) {
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasscodeProvider);
    final isConfirm = state.phase == ResetPasscodePhase.confirm;
    final isOtp = state.phase == ResetPasscodePhase.otp;

    ref.listen(resetPasscodeProvider, (_, next) {
      if (next.snackbarError != null) {
        AppSnackbar.error(context, next.snackbarError!);
        ref.read(resetPasscodeProvider.notifier).clearSnackbarError();
      }
    });

    final title = isOtp
        ? AppStrings.enterVerificationCode
        : isConfirm
            ? AppStrings.confirmPasscode
            : AppStrings.createNewPasscode;

    final subtitle = isOtp
        ? '${AppStrings.verificationSubtitle}${widget.email}'
        : isConfirm
            ? AppStrings.confirmNewPasscodeSubtitle
            : AppStrings.createPasscodeSubtitle;

    final stepLabel = isOtp
        ? AppStrings.step1of3
        : isConfirm
            ? AppStrings.step3of3
            : AppStrings.step2of3;

    return PopScope(
      canPop: state.phase == ResetPasscodePhase.otp,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackTap();
      },
      child: Scaffold(
        backgroundColor: context.scaffoldColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(onBack: _onBackTap, stepLabel: stepLabel),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              key: ValueKey(title),
                              child: AppScreenHeader(
                                title: title,
                                subtitle: subtitle,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppOtpField(
                            controller: _controller,
                            obscureText: !isOtp,
                            hasError: state.hasError,
                            errorText: state.errorText,
                            onChanged: (_) =>
                                ref.read(resetPasscodeProvider.notifier).clearError(),
                            onCompleted: _onCompleted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.isLoading || state.isSendingOtp) const AppLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

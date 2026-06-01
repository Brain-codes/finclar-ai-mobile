import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_loading_overlay.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_link.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../providers/change_passcode_provider.dart';

class ChangePasscodeScreen extends ConsumerStatefulWidget {
  const ChangePasscodeScreen({super.key});

  @override
  ConsumerState<ChangePasscodeScreen> createState() => _ChangePasscodeScreenState();
}

class _ChangePasscodeScreenState extends ConsumerState<ChangePasscodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBack() {
    final phase = ref.read(changePasscodeProvider).phase;
    _controller.clear();
    if (phase == ChangePasscodePhase.confirm) {
      ref.read(changePasscodeProvider.notifier).backToCreate();
    } else if (phase == ChangePasscodePhase.create) {
      ref.read(changePasscodeProvider.notifier).backToOtp();
    } else {
      if (context.canPop()) context.pop();
    }
  }

  Future<void> _onCompleted(String code) async {
    final notifier = ref.read(changePasscodeProvider.notifier);
    final phase = ref.read(changePasscodeProvider).phase;
    _controller.clear();

    if (phase == ChangePasscodePhase.otp) {
      notifier.onOtpEntered(code);
    } else if (phase == ChangePasscodePhase.create) {
      notifier.onNewPasscodeCreated(code);
    } else {
      final success = await notifier.onNewPasscodeConfirmed(code);
      if (success && mounted) {
        AppSnackbar.success(context, 'Passcode updated successfully');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasscodeProvider);

    ref.listen(changePasscodeProvider, (_, next) {
      if (next.snackbarError != null) {
        AppSnackbar.error(context, next.snackbarError!);
        ref.read(changePasscodeProvider.notifier).clearSnackbarError();
      }
      if (next.snackbarSuccess != null) {
        AppSnackbar.success(context, next.snackbarSuccess!);
        ref.read(changePasscodeProvider.notifier).clearSnackbarSuccess();
      }
    });

    final isOtp = state.phase == ChangePasscodePhase.otp;
    final isConfirm = state.phase == ChangePasscodePhase.confirm;

    final title = isOtp
        ? 'Verify it\'s you'
        : isConfirm
            ? 'Confirm new passcode'
            : 'New passcode';

    final subtitle = isOtp
        ? 'We sent a 6-digit code to your email. Enter it below.'
        : isConfirm
            ? 'Re-enter your new passcode to confirm'
            : "Enter a passcode you'll remember";

    return PopScope(
      canPop: isOtp,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: context.scaffoldColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(onBack: _onBack, circleBack: true),
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
                              key: ValueKey(state.phase),
                              alignment: Alignment.centerLeft,
                              child: AppScreenHeader(
                                title: title,
                                subtitle: subtitle,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppOtpField(
                            controller: _controller,
                            autofocus: true,
                            obscureText: !isOtp,
                            hasError: state.hasError,
                            errorText: state.errorText,
                            onChanged: (_) =>
                                ref.read(changePasscodeProvider.notifier).clearError(),
                            onCompleted: _onCompleted,
                          ),
                          if (isOtp) ...[
                            const SizedBox(height: AppSpacing.base),
                            Center(
                              child: AppTextLink(
                                prompt: 'Didn\'t receive the code? ',
                                actionLabel: 'Resend',
                                onTap: () {
                                  if (!state.isSendingOtp) {
                                    ref.read(changePasscodeProvider.notifier).resendOtp();
                                  }
                                },
                              ),
                            ),
                          ],
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

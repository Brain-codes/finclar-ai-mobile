import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_loading_overlay.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../providers/passcode_provider.dart';
import '../../providers/sign_up_provider.dart';

class PasscodeScreen extends ConsumerStatefulWidget {
  const PasscodeScreen({super.key});

  @override
  ConsumerState<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends ConsumerState<PasscodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBackTap() {
    final phase = ref.read(passcodeProvider).phase;
    if (phase == PasscodePhase.confirm) {
      _controller.clear();
      ref.read(passcodeProvider.notifier).backToCreate();
    } else {
      context.pop();
    }
  }

  Future<void> _onCompleted(String code) async {
    final notifier = ref.read(passcodeProvider.notifier);
    final phase = ref.read(passcodeProvider).phase;

    if (phase == PasscodePhase.create) {
      _controller.clear();
      notifier.onPasscodeCreated(code);
    } else {
      final success = await notifier.onPasscodeConfirmed(code);
      if (success && mounted) {
        final email = ref.read(signUpProvider).email;
        context.push(RouteNames.verifyEmail, extra: email);
      } else if (mounted) {
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passcodeProvider);
    final isConfirm = state.phase == PasscodePhase.confirm;

    ref.listen(passcodeProvider, (prev, next) {
      if (next.apiError != null && next.apiError != prev?.apiError) {
        AppSnackbar.error(context, next.apiError!);
        ref.read(passcodeProvider.notifier).clearApiError();
      }
    });

    final title = isConfirm
        ? AppStrings.confirmPasscode
        : AppStrings.createPasscode;
    final subtitle = isConfirm
        ? AppStrings.confirmPasscodeSubtitle
        : AppStrings.createPasscodeSubtitle;

    return PopScope(
      canPop: !isConfirm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _controller.clear();
          ref.read(passcodeProvider.notifier).backToCreate();
        }
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
                  AppTopBar(onBack: _onBackTap, stepLabel: AppStrings.step2of3),
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
                              key: ValueKey(title + subtitle),
                              child: AppScreenHeader(
                                title: title,
                                subtitle: subtitle,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppOtpField(
                            controller: _controller,
                            obscureText: true,
                            hasError: state.hasError,
                            errorText: state.errorText,
                            onChanged: (_) => ref
                                .read(passcodeProvider.notifier)
                                .clearError(),
                            onCompleted: _onCompleted,
                          ),
                        ],
                      ),
                    ),
                  ),
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

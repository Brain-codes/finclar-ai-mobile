import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../providers/reset_passcode_provider.dart';

class ResetPasscodeScreen extends ConsumerStatefulWidget {
  const ResetPasscodeScreen({super.key});

  @override
  ConsumerState<ResetPasscodeScreen> createState() =>
      _ResetPasscodeScreenState();
}

class _ResetPasscodeScreenState extends ConsumerState<ResetPasscodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBackTap() {
    final phase = ref.read(resetPasscodeProvider).phase;
    if (phase == ResetPasscodePhase.confirm) {
      _controller.clear();
      ref.read(resetPasscodeProvider.notifier).backToCreate();
    } else {
      context.pop();
    }
  }

  Future<void> _onCompleted(String code) async {
    final notifier = ref.read(resetPasscodeProvider.notifier);
    final phase = ref.read(resetPasscodeProvider).phase;

    if (phase == ResetPasscodePhase.create) {
      _controller.clear();
      notifier.onPasscodeCreated(code);
    } else {
      final success = await notifier.onPasscodeConfirmed(code);
      if (success && mounted) {
        context.go(RouteNames.login);
      } else if (mounted) {
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasscodeProvider);
    final isConfirm = state.phase == ResetPasscodePhase.confirm;

    final title =
        isConfirm ? AppStrings.confirmPasscode : AppStrings.createNewPasscode;
    final subtitle = isConfirm
        ? AppStrings.confirmNewPasscodeSubtitle
        : AppStrings.createPasscodeSubtitle;
    final stepLabel =
        isConfirm ? AppStrings.step3of3 : AppStrings.step2of3;

    return PopScope(
      canPop: !isConfirm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _controller.clear();
          ref.read(resetPasscodeProvider.notifier).backToCreate();
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
                            obscureText: true,
                            hasError: state.hasError,
                            errorText: state.errorText,
                            onChanged: (_) => ref
                                .read(resetPasscodeProvider.notifier)
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
          ],
        ),
      ),
    );
  }
}

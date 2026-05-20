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
import '../../providers/passcode_provider.dart';

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
        context.pushReplacement(RouteNames.preference);
      } else if (mounted) {
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passcodeProvider);
    final isConfirm = state.phase == PasscodePhase.confirm;

    final title = isConfirm
        ? AppStrings.confirmPasscode
        : AppStrings.createPasscode;
    final subtitle = isConfirm
        ? AppStrings.confirmPasscodeSubtitle
        : AppStrings.createPasscodeSubtitle;

    return PopScope(
      // Allow the OS to pop when in create phase (swipe-back exits the screen).
      // Block it in confirm phase so the gesture goes back to create instead.
      canPop: !isConfirm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Only fires in confirm phase (canPop == false).
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
                  // ── Top bar ──────────────────────────────────────────────────
                  AppTopBar(onBack: _onBackTap, stepLabel: AppStrings.step3of3),

                  // ── Body ─────────────────────────────────────────────────────
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
          ],
        ),
      ),
    );
  }
}

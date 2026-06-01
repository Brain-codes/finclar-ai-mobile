import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../providers/forgot_passcode_provider.dart';

class ForgotPasscodeScreen extends ConsumerStatefulWidget {
  const ForgotPasscodeScreen({super.key});

  @override
  ConsumerState<ForgotPasscodeScreen> createState() =>
      _ForgotPasscodeScreenState();
}

class _ForgotPasscodeScreenState extends ConsumerState<ForgotPasscodeScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final success = await ref
        .read(forgotPasscodeProvider.notifier)
        .sendCode(_emailController.text.trim());
    if (success && mounted) {
      context.push(RouteNames.resetPasscode, extra: _emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasscodeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/GRADIENT.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                AppTopBar(onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        const AppScreenHeader(
                          title: AppStrings.forgotPasscodeEmailTitle,
                          subtitle: AppStrings.forgotPasscodeEmailSubtitle,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppTextField(
                          label: AppStrings.emailAddress,
                          hint: AppStrings.enterEmailAddress,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          errorText: state.hasError ? state.errorText : null,
                          onChanged: (_) => ref
                              .read(forgotPasscodeProvider.notifier)
                              .clearError(),
                          onEditingComplete:
                              state.isLoading ? null : _onContinue,
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

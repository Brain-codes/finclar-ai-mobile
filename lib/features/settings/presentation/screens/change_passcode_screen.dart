import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_screen_header.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';

class ChangePasscodeScreen extends StatefulWidget {
  const ChangePasscodeScreen({super.key});

  @override
  State<ChangePasscodeScreen> createState() => _ChangePasscodeScreenState();
}

class _ChangePasscodeScreenState extends State<ChangePasscodeScreen> {
  final _controller = TextEditingController();
  int _step = 0;
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBack() {
    if (_step == 1) {
      setState(() {
        _step = 0;
        _hasError = false;
        _controller.clear();
      });
    } else {
      context.pop();
    }
  }

  Future<void> _onCompleted(String code) async {
    if (_step == 0) {
      setState(() {
        _step = 1;
        _hasError = false;
      });
      _controller.clear();
    } else {
      if (mounted) {
        AppSnackbar.success(context, 'Passcode updated successfully');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = _step == 1;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: context.scaffoldColor,
        body: SafeArea(
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
                          key: ValueKey(_step),
                          alignment: Alignment.centerLeft,
                          child: AppScreenHeader(
                            title: isNew ? 'New passcode' : 'Current passcode',
                            subtitle: isNew
                                ? "Enter a passcode you'll remember"
                                : 'Enter your current passcode to continue',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppOtpField(
                        controller: _controller,
                        autofocus: true,
                        obscureText: true,
                        hasError: _hasError,
                        errorText: 'Incorrect passcode, try again',
                        onChanged: (_) => setState(() => _hasError = false),
                        onCompleted: _onCompleted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class ForgotPasscodeScreen extends StatelessWidget {
  const ForgotPasscodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text(AppStrings.forgotPasscodeTitle)),
    );
  }
}

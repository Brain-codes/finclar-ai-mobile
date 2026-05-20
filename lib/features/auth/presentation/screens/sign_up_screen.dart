import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text(AppStrings.signUp)),
    );
  }
}

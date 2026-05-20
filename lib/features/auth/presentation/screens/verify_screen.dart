import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

enum VerifyType { email, phone }

class VerifyScreen extends StatelessWidget {
  final VerifyType type;

  const VerifyScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(type == VerifyType.email
            ? AppStrings.verifyEmail
            : AppStrings.verifyPhone),
      ),
    );
  }
}

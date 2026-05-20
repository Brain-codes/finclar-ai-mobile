import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.subscription)),
      body: const Center(child: Text(AppStrings.subscription)),
    );
  }
}

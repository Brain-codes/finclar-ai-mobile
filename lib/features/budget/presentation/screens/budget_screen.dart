import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.budget)),
      body: const Center(child: Text(AppStrings.budget)),
    );
  }
}

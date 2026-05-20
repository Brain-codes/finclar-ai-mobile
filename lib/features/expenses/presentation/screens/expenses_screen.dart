import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.expenses)),
      body: const Center(child: Text(AppStrings.expenses)),
    );
  }
}

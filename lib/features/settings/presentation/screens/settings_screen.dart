import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: const Center(child: Text(AppStrings.settings)),
    );
  }
}

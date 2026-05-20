import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.groups)),
      body: const Center(child: Text(AppStrings.groups)),
    );
  }
}

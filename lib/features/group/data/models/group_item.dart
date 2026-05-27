import 'package:flutter/material.dart';

class GroupItem {
  final String name;
  final String amountSaved;
  final String daysLeft;
  final String target;
  final double progress;
  final Color themeColor;

  const GroupItem({
    required this.name,
    required this.amountSaved,
    required this.daysLeft,
    required this.target,
    required this.progress,
    required this.themeColor,
  });
}

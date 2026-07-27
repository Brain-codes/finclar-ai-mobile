import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/icons/app_icons.dart';

/// Curated icon keys for the category icon picker.
/// Keys are the actual Remix icon field names — the exact string stored in
/// `CategoryModel.icon` and sent to `POST /categories`.
const List<(String, String)> categoryPickerIcons = [
  ('restaurant_line', 'Food'),
  ('car_line', 'Transport'),
  ('heart_pulse_line', 'Health'),
  ('shopping_bag_line', 'Shopping'),
  ('movie_line', 'Fun'),
  ('flashlight_line', 'Bills'),
  ('plane_line', 'Travel'),
  ('home_6_line', 'Home'),
  ('briefcase_4_fill', 'Work'),
  ('bank_line', 'Finance'),
  ('wallet_line', 'Wallet'),
  ('bar_chart_fill', 'Stats'),
  ('calendar_line', 'Events'),
  ('star_line', 'Savings'),
  ('more_2_line', 'Other'),
];

/// Maps a Remix icon name string (e.g. `"star_line"`) back to an [IconData].
IconData categoryIconFromString(String? key) {
  switch (key) {
    case 'restaurant_line':  return AppIcons.categoryFood;
    case 'car_line':         return AppIcons.categoryTransport;
    case 'heart_pulse_line': return AppIcons.categoryHealth;
    case 'shopping_bag_line': return AppIcons.categoryShopping;
    case 'movie_line':       return AppIcons.categoryEntertainment;
    case 'flashlight_line':  return AppIcons.categoryUtilities;
    case 'plane_line':       return AppIcons.categoryTravel;
    case 'home_6_line':      return AppIcons.home;
    case 'briefcase_4_fill': return AppIcons.briefcase;
    case 'bank_line':        return AppIcons.bank;
    case 'wallet_line':      return AppIcons.walletLine;
    case 'bar_chart_fill':   return AppIcons.chart;
    case 'calendar_line':    return AppIcons.calendar;
    case 'star_line':        return AppIcons.star;
    default:                 return AppIcons.categoryOther;
  }
}

Color expenseCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppColors.categoryFood;
    case 'transport':
    case 'transportation':
      return AppColors.categoryTransport;
    case 'health':
      return AppColors.categoryHealth;
    case 'shopping':
      return AppColors.categoryShopping;
    case 'utilities':
    case 'bills':
      return AppColors.categoryUtilities;
    default:
      return AppColors.primary;
  }
}

Color expenseCategoryBgColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppColors.categoryFoodBg;
    case 'transport':
    case 'transportation':
      return AppColors.categoryTransportBg;
    case 'health':
      return AppColors.categoryHealthBg;
    case 'shopping':
      return AppColors.categoryShoppingBg;
    case 'utilities':
    case 'bills':
      return AppColors.categoryUtilitiesBg;
    default:
      return AppColors.primaryMuted;
  }
}

IconData expenseCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppIcons.categoryFood;
    case 'transport':
    case 'transportation':
      return AppIcons.categoryTransport;
    case 'health':
      return AppIcons.categoryHealth;
    case 'shopping':
      return AppIcons.categoryShopping;
    case 'utilities':
    case 'bills':
      return AppIcons.categoryUtilities;
    default:
      return AppIcons.wallet;
  }
}

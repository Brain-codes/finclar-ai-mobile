import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/icons/app_icons.dart';

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

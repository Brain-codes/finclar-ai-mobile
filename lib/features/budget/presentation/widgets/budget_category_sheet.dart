import 'package:flutter/material.dart';
import '../../../expenses/data/models/category_model.dart';
import '../../../expenses/presentation/widgets/expense_category_sheet.dart';

// Delegates to the centralized expense category sheet so budget and expense
// flows share one picker (including the "Add category" create option).
Future<CategoryModel?> showBudgetCategorySheet(
  BuildContext context, {
  CategoryModel? selected,
}) {
  return showExpenseCategorySheet(context, selectedId: selected?.id);
}

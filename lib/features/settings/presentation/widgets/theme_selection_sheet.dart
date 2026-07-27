import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';

Future<void> showThemeSelectionSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    title: 'Appearance',
    children: const [_ThemeSelectionContent()],
  );
}

class _ThemeSelectionContent extends ConsumerWidget {
  const _ThemeSelectionContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThemeOption(
          icon: AppIcons.themeLight,
          label: 'Light',
          selected: current == ThemeMode.light,
          onTap: notifier.setLight,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ThemeOption(
          icon: AppIcons.themeDark,
          label: 'Dark',
          selected: current == ThemeMode.dark,
          onTap: notifier.setDark,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ThemeOption(
          icon: AppIcons.themeSystem,
          label: 'System default',
          selected: current == ThemeMode.system,
          onTap: notifier.setSystem,
        ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryMuted : context.surfaceVariant,
          borderRadius: AppRadius.radiusCard,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : context.textTertiary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: selected ? AppColors.primary : context.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              selected ? AppIcons.radioChecked : AppIcons.radioUnchecked,
              size: 20,
              color: selected ? AppColors.primary : context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

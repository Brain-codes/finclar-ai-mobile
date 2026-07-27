import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../data/models/income_source_model.dart';
import '../../providers/income_setup_provider.dart';
import 'add_source_sheet.dart';

Future<IncomeSourceModel?> showSelectSourceSheet(
  BuildContext context, {
  IncomeSourceModel? selected,
}) {
  return showAppSheet<IncomeSourceModel>(
    context,
    title: 'Select source',
    children: [
      _SelectSourceContent(initialSelected: selected),
    ],
  );
}

class _SelectSourceContent extends ConsumerStatefulWidget {
  final IncomeSourceModel? initialSelected;
  const _SelectSourceContent({this.initialSelected});

  @override
  ConsumerState<_SelectSourceContent> createState() =>
      _SelectSourceContentState();
}

class _SelectSourceContentState extends ConsumerState<_SelectSourceContent> {
  IncomeSourceModel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  Future<void> _addSource() async {
    final result = await showAddSourceSheet(context);
    if (result != null) setState(() => _selected = result);
  }

  @override
  Widget build(BuildContext context) {
    final sourcesAsync = ref.watch(incomeSourcesProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sourcesAsync.when(
          loading: () => const SkeletonCard(),
          error: (_, _) => const SizedBox.shrink(),
          data: (sources) => Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusSheet,
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                for (int i = 0; i < sources.length; i++) ...[
                  _SourceRow(
                    label: sources[i].name,
                    isSelected: _selected?.id == sources[i].id,
                    onTap: () => setState(() => _selected = sources[i]),
                  ),
                  if (i < sources.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.borderColor,
                      indent: AppSpacing.base,
                      endIndent: AppSpacing.base,
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _addSource,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.add, size: 15, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Add source',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontVariations: const [FontVariation('wght', 500)],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        AppButton(
          label: 'Continue',
          onTap: _selected != null
              ? () => Navigator.of(context).pop(_selected)
              : null,
          height: 48,
        ),
      ],
    );
  }
}

class _SourceRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SourceRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textPrimary,
                fontVariations: const [FontVariation('wght', 500)],
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? AppIcons.radioChecked : AppIcons.circle,
              size: 20,
              color: isSelected ? AppColors.primary : context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

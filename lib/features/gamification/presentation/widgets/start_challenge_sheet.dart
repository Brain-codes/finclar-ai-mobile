import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../expenses/presentation/widgets/expense_category_sheet.dart';
import '../../data/models/challenge_model.dart';
import '../../providers/challenge_providers.dart';
import 'challenge_utils.dart';

/// Creates a challenge of [type], or edits [existing] when passed (its own type
/// wins). Returns the saved challenge, or null when dismissed.
/// [endDate] closes the challenge on a fixed day — windowed types pass the end
/// of their window so the backend expires them rather than leaving them running
/// past the point they mean anything.
Future<ChallengeModel?> showStartChallengeSheet(
  BuildContext context, {
  ChallengeModel? existing,
  ChallengeType type = ChallengeType.fridaySavings,
  DateTime? endDate,
}) {
  final effective = existing?.type ?? type;
  return showAppSheet<ChallengeModel>(
    context,
    title: existing == null ? challengeTypeLabel(effective) : 'Edit challenge',
    avoidKeyboard: true,
    children: [
      _StartChallengeForm(
        existing: existing,
        type: effective,
        endDate: endDate,
      ),
    ],
  );
}

class _StartChallengeForm extends ConsumerStatefulWidget {
  final ChallengeModel? existing;
  final ChallengeType type;
  final DateTime? endDate;

  const _StartChallengeForm({
    required this.existing,
    required this.type,
    this.endDate,
  });

  @override
  ConsumerState<_StartChallengeForm> createState() =>
      _StartChallengeFormState();
}

class _StartChallengeFormState extends ConsumerState<_StartChallengeForm> {
  late final TextEditingController _weeklyController;
  late final TextEditingController _overallController;
  String? _categoryId;
  String? _categoryName;
  bool _isSaving = false;

  bool get _spendBased => widget.type.isSpendBased;

  /// Spend-based types are capped by `overall_target`, so that field carries
  /// the whole form and the weekly one is never shown.
  bool get _canSave => _spendBased
      ? _overall > 0 &&
            (widget.type != ChallengeType.budgetCategory || _categoryId != null)
      : _weekly > 0;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _weeklyController = TextEditingController(
      text: e?.weeklyTarget == null ? '' : formatAmountInput(e!.weeklyTarget!),
    );
    _overallController = TextEditingController(
      text: e?.overallTarget == null
          ? ''
          : formatAmountInput(e!.overallTarget!),
    );
    _categoryId = e?.targetCategoryId;
  }

  @override
  void dispose() {
    _weeklyController.dispose();
    _overallController.dispose();
    super.dispose();
  }

  double get _weekly => parseAmountInput(_weeklyController.text);
  double get _overall => parseAmountInput(_overallController.text);

  Future<void> _pickCategory() async {
    final picked = await showExpenseCategorySheet(
      context,
      selectedId: _categoryId,
    );
    if (picked == null) return;
    setState(() {
      _categoryId = picked.id;
      _categoryName = picked.name;
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _isSaving = true);
    final notifier = ref.read(challengesProvider.notifier);
    try {
      final saved = widget.existing == null
          ? await notifier.create(
              type: widget.type,
              weeklyTarget: _spendBased ? null : _weekly,
              overallTarget: _overall > 0 ? _overall : null,
              targetCategoryId: _categoryId,
              endDate: widget.endDate,
            )
          : await notifier.edit(
              widget.existing!.id,
              weeklyTarget: _spendBased ? null : _weekly,
              overallTarget: _overall > 0 ? _overall : null,
            );
      if (!mounted) return;
      Navigator.of(context).pop(saved);
      AppSnackbar.success(
        context,
        widget.existing == null ? 'Challenge started' : 'Challenge updated',
      );
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackbar.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(currencySymbolProvider);
    final prefixStyle = AppTypography.bodyMedium.copyWith(
      color: context.textSecondary,
    );
    // Editing arrives with an id but no name — resolve it off the cached list
    // so the row doesn't read "Selected".
    final categoryName =
        _categoryName ??
        (_categoryId == null
            ? null
            : ref
                  .watch(categoriesProvider)
                  .where((c) => c.id == _categoryId)
                  .firstOrNull
                  ?.name);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.existing == null) ...[
          Text(
            challengeTypeBlurb(widget.type),
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (widget.type == ChallengeType.budgetCategory) ...[
          // `UpdateChallengeDto` has no `target_category_id`, so the category
          // is fixed once the challenge exists — shown, but not tappable.
          _CategoryRow(
            value: categoryName ?? 'Select',
            onTap: _isSaving || widget.existing != null ? null : _pickCategory,
          ),
          const SizedBox(height: AppSpacing.base),
        ],
        if (!_spendBased) ...[
          AppTextField(
            label: 'Weekly target',
            hint: 'Enter amount',
            controller: _weeklyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [CurrencyInputFormatter()],
            prefixText: '$symbol ',
            prefixStyle: prefixStyle,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.base),
        ],
        AppTextField(
          label: _spendBased ? 'Spend cap' : 'Overall goal (optional)',
          hint: _spendBased
              ? 'The most you can spend'
              : 'What you want to save in total',
          controller: _overallController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [CurrencyInputFormatter()],
          prefixText: '$symbol ',
          prefixStyle: prefixStyle,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _spendBased
              ? 'Go over this and the challenge is lost. Set it somewhere you '
                    'have to work for it.'
              : 'Set an overall goal to track progress. Leave it blank to just '
                    'keep the streak going.',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: widget.existing == null ? 'Start challenge' : 'Save changes',
          onTap: _canSave ? _save : null,
          isLoading: _isSaving,
          height: 52,
        ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String value;
  final VoidCallback? onTap;

  const _CategoryRow({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: AppRadius.radiusCard,
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Text(
              'Category',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textPrimary,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                AppIcons.chevronRight,
                size: 16,
                color: context.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

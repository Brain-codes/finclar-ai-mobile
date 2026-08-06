import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

final _numberFormat = NumberFormat('#,##0', 'en');

/// Edit a member's target contribution. Returns the new amount when saved,
/// or null if cancelled/removed. [onRemove] fires when "Remove user" is tapped.
Future<double?> showEditFriendSheet(
  BuildContext context, {
  required String name,
  required String contributed,
  required String target,
  required String symbol,
  required VoidCallback onRemove,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _EditFriendSheet(
      name: name,
      contributed: contributed,
      target: target,
      symbol: symbol,
      onRemove: onRemove,
    ),
  );
}

class _EditFriendSheet extends StatefulWidget {
  final String name;
  final String contributed;
  final String target;
  final String symbol;
  final VoidCallback onRemove;

  const _EditFriendSheet({
    required this.name,
    required this.contributed,
    required this.target,
    required this.symbol,
    required this.onRemove,
  });

  @override
  State<_EditFriendSheet> createState() => _EditFriendSheetState();
}

class _EditFriendSheetState extends State<_EditFriendSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAmountChanged(String raw) {
    final digits = raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _controller.value = const TextEditingValue(text: '');
      setState(() {});
      return;
    }
    final n = int.tryParse(digits) ?? 0;
    final formatted = _numberFormat.format(n);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit details',
                style: AppTypography.labelLarge.copyWith(
                  color: context.textPrimary,
                  fontFamily: AppFonts.display,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderStrong),
                  ),
                  child: Icon(AppIcons.close, size: 16, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                AppProfileAvatar(
                  profileIcon: null,
                  name: widget.name,
                  size: 56,
                  seedWhenEmpty: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.name,
                  style: AppTypography.headingSmall.copyWith(
                    color: context.textPrimary,
                    fontFamily: AppFonts.display,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.contributed} contributed / ${widget.target}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Edit amount',
            hint: 'Enter amount',
            controller: _controller,
            keyboardType: TextInputType.number,
            onChanged: _onAmountChanged,
            prefixText: '${widget.symbol} ',
            prefixStyle: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Save changes',
                  onTap: _controller.text.isNotEmpty
                      ? () => Navigator.of(context).pop(
                            double.tryParse(
                                _controller.text.replaceAll(',', '')),
                          )
                      : null,
                  height: 48,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Remove user',
                  variant: AppButtonVariant.outline,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onRemove();
                  },
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

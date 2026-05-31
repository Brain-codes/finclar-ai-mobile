import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_date_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../widgets/add_friend_sheet.dart';
import '../../../../core/config/app_config_notifier.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');
final _numberFormat = NumberFormat('#,##0', 'en');

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _endDate;
  final List<String> _friends = [];

  // At least name + amount + 1 friend added (you + 1)
  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      _friends.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String raw) {
    final digits = raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _amountController.value = const TextEditingValue(text: '');
      setState(() {});
      return;
    }
    final n = int.tryParse(digits) ?? 0;
    final formatted = _numberFormat.format(n);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showAppDateSheet(
      context,
      initial: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _addFriend() async {
    final name = await showAddFriendSheet(context);
    if (name != null && !_friends.contains(name)) {
      setState(() => _friends.add(name));
    }
  }

  void _onCreate() {
    AppSnackbar.success(context, 'Group created successfully');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(currencySymbolProvider);
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.base),
                    _BackButton(),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      'Create group',
                      style: AppTypography.headingLarge.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: 'Name of group',
                      hint: 'Enter group name',
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    AppTextField(
                      label: 'Amount',
                      hint: 'Enter amount',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: _onAmountChanged,
                      prefixText: '$symbol ',
                      prefixStyle: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _DateField(
                      label: 'End date',
                      value: _endDate != null
                          ? _dateFormat.format(_endDate!)
                          : null,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _AddFriendsSection(friends: _friends, onAddTap: _addFriend),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            _BottomBar(canCreate: _canCreate, onTap: _onCreate),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: context.borderColor),
        ),
        child: Icon(AppIcons.back, size: 20, color: context.textPrimary),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: context.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.inputBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? 'dd/mm/yyyy',
                    style: AppTypography.bodyMedium.copyWith(
                      color: value != null
                          ? context.textPrimary
                          : context.inputPlaceholder,
                    ),
                  ),
                ),
                Icon(AppIcons.calendar, size: 18, color: context.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddFriendsSection extends StatelessWidget {
  final List<String> friends;
  final VoidCallback onAddTap;

  const _AddFriendsSection({required this.friends, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add friends',
            style: AppTypography.bodySmall.copyWith(
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MemberSlot(label: 'You', isYou: true),
                ...friends.map((name) {
                  final initials = name
                      .trim()
                      .split(' ')
                      .map((w) => w[0])
                      .take(2)
                      .join();
                  return Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _MemberSlot(label: initials),
                  );
                }),
                const SizedBox(width: AppSpacing.sm),
                _AddSlot(onTap: onAddTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberSlot extends StatelessWidget {
  final String label;
  final bool isYou;

  const _MemberSlot({required this.label, this.isYou = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isYou ? AppColors.primaryMuted : const Color(0xFFB8DFF2),
            shape: BoxShape.circle,
          ),
          child: isYou
              ? const Icon(AppIcons.user, size: 24, color: AppColors.primary)
              : Center(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF1A6B9A),
                      fontVariations: const [FontVariation('wght', 600)],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          isYou ? 'You' : label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AddSlot extends StatelessWidget {
  final VoidCallback onTap;

  const _AddSlot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.scaffoldColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.borderColor),
            ),
            child: Icon(
              AppIcons.addCircle,
              size: 20,
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: AppTypography.labelSmall.copyWith(
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool canCreate;
  final VoidCallback onTap;

  const _BottomBar({required this.canCreate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: AppButton(
        label: 'Create group',
        onTap: canCreate ? onTap : null,
        height: 52,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_date_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/friendship_model.dart';
import '../../providers/group_providers.dart';
import '../widgets/add_friend_sheet.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';
import '../../../auth/providers/user_profile_provider.dart';

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
  final List<UserSearchResultModel> _friends = [];
  bool _isSubmitting = false;

  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      _endDate != null &&
      !_isSubmitting;

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
    final selected = await showAddFriendSheet(
      context,
      excludeIds: _friends.map((f) => f.id).toSet(),
    );
    if (selected != null && !_friends.any((f) => f.id == selected.id)) {
      setState(() => _friends.add(selected));
    }
  }

  double get _amountValue =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

  Future<void> _onCreate() async {
    setState(() => _isSubmitting = true);
    try {
      final group = await ref.read(groupsProvider.notifier).create(
            name: _nameController.text.trim(),
            targetAmount: _amountValue,
            endDate: _endDate!,
            memberIds: _friends.map((f) => f.id).toList(),
          );
      if (!mounted) return;
      AppSnackbar.success(context, 'Group created successfully');
      // Replace the create screen with the new group's detail so back
      // returns to the group list, not the create form.
      context.pushReplacement(RouteNames.groupDetail, extra: group);
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackbar.error(context, e.message);
      }
    }
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
                    _AddFriendsSection(
                      friends: _friends,
                      onAddTap: _addFriend,
                      myProfileIcon: ref
                          .watch(userProfileProvider)
                          .valueOrNull
                          ?.profileIcon,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            _BottomBar(
              canCreate: _canCreate,
              isLoading: _isSubmitting,
              onTap: _onCreate,
            ),
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
  final List<UserSearchResultModel> friends;
  final VoidCallback onAddTap;
  final String? myProfileIcon;

  const _AddFriendsSection({
    required this.friends,
    required this.onAddTap,
    this.myProfileIcon,
  });

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
                _MemberSlot(
                  label: 'You',
                  isYou: true,
                  profileIcon: myProfileIcon,
                ),
                ...friends.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _MemberSlot(label: f.username),
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

  /// The current user's own `profile_icon` for the "You" slot. Friends have
  /// none yet, so their faces are generated from [label].
  final String? profileIcon;

  const _MemberSlot({
    required this.label,
    this.isYou = false,
    this.profileIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isYou && (profileIcon == null || profileIcon!.isEmpty))
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.user, size: 24, color: AppColors.primary),
          )
        else
          AppProfileAvatar(
            profileIcon: isYou ? profileIcon : null,
            name: label,
            size: 56,
            seedWhenEmpty: !isYou,
          ),
        const SizedBox(height: 4),
        SizedBox(
          width: 56,
          child: Text(
            isYou ? 'You' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondary,
            ),
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
  final bool isLoading;
  final VoidCallback onTap;

  const _BottomBar({
    required this.canCreate,
    required this.isLoading,
    required this.onTap,
  });

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
        isLoading: isLoading,
        height: 52,
      ),
    );
  }
}

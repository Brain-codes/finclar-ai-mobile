import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nice_avatar/nice_avatar.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../widgets/avatar_customiser.dart';
import '../widgets/avatar_choice_sections.dart';

enum _Tab { presets, customise }

class AvatarPickerScreen extends ConsumerStatefulWidget {
  const AvatarPickerScreen({super.key});

  @override
  ConsumerState<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends ConsumerState<AvatarPickerScreen> {
  _Tab _tab = _Tab.presets;
  bool _isSaving = false;

  String? _originalIcon;

  /// Set only while a ready-made avatar is selected untouched — as soon as any
  /// part is customised we fall back to storing the encoded config.
  String? _selectedChoiceValue;

  ResolvedAvatarConfig? _config;
  List<String> _recommendedSeeds = const [];

  /// Seeds the editor from whatever is stored, falling back to a fresh random
  /// face so the customiser always has something to work with.
  void _initFrom(UserModel? user) {
    if (_config != null) return;
    if (user == null) {
      _config = genConfig();
      return;
    }
    _recommendedSeeds = recommendedAvatarSeeds(user);
    final stored = user.profileIcon;
    _originalIcon = stored;
    if (stored != null && stored.isNotEmpty) {
      _selectedChoiceValue = stored;
      _config = configFromString(stored);
    } else {
      _config = genConfig();
    }
  }

  /// A ready-made avatar keeps whatever value its tile carries — a preset id,
  /// or an encoded config for a recommended one. Anything customised is stored
  /// as an encoded config. Both come back through `configFromString`.
  String get _valueToStore => _selectedChoiceValue ?? _config!.encode();

  bool get _hasChanges => _valueToStore != _originalIcon;

  void _onChoiceSelected(String value) {
    setState(() {
      _selectedChoiceValue = value;
      _config = configFromString(value);
    });
  }

  void _onConfigChanged(ResolvedAvatarConfig config) {
    setState(() {
      _config = config;
      _selectedChoiceValue = null;
    });
  }

  void _onShuffle() {
    setState(() {
      _config = genConfig();
      _selectedChoiceValue = null;
    });
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(profileIcon: _valueToStore);
      if (!mounted) return;
      AppSnackbar.success(context, 'Avatar updated');
      if (context.canPop()) context.pop();
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).valueOrNull;
    _initFrom(user);
    final config = _config!;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppTopBar(
                title: 'Profile avatar',
                circleBack: true,
                onBack: () => context.canPop() ? context.pop() : null,
                actions: [
                  AppTopBarAction(icon: AppIcons.refresh, onTap: _onShuffle),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            NiceAvatar(config: config, size: 120),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _TabSwitcher(
                selected: _tab,
                onChanged: (tab) => setState(() => _tab = tab),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: switch (_tab) {
                  _Tab.presets => AvatarChoiceSections(
                      recommendedSeeds: _recommendedSeeds,
                      selectedValue: _selectedChoiceValue,
                      onSelected: _onChoiceSelected,
                    ),
                  _Tab.customise => AvatarCustomiser(
                      config: config,
                      onChanged: _onConfigChanged,
                    ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: 'Save changes',
                height: 48,
                isLoading: _isSaving,
                onTap: _hasChanges && !_isSaving ? _onSave : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final _Tab selected;
  final ValueChanged<_Tab> onChanged;

  const _TabSwitcher({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Ready-made',
            isSelected: selected == _Tab.presets,
            onTap: () => onChanged(_Tab.presets),
          ),
          _TabButton(
            label: 'Customise',
            isSelected: selected == _Tab.customise,
            onTap: () => onChanged(_Tab.customise),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? context.surfaceColor : Colors.transparent,
            borderRadius: AppRadius.radiusFull,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 14,
              color: isSelected ? AppColors.primary : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

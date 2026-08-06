import 'package:flutter/material.dart';
import 'package:nice_avatar/nice_avatar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/data/models/user_model.dart';

/// Deterministic seeds derived from the user themselves, so "recommended"
/// means the same faces every time they open the picker — and different faces
/// from the next person's.
///
/// The account id is preferred over the username because a username can be
/// changed, which would silently reshuffle the suggestions.
List<String> recommendedAvatarSeeds(UserModel user, {int count = 8}) {
  final base = [user.id, user.username, user.email]
      .firstWhere((v) => v.trim().isNotEmpty, orElse: () => 'finclar');
  return [
    for (var i = 0; i < count; i++) i == 0 ? base : '$base#$i',
  ];
}

/// One selectable avatar: what it looks like, and what gets written to
/// `profile_icon` when it is picked.
class AvatarChoice {
  final ResolvedAvatarConfig config;
  final String value;

  const AvatarChoice({required this.config, required this.value});

  /// Recommended avatars are stored as a full encoded config — the seed itself
  /// is derived from the account id and would mean nothing to anyone else.
  factory AvatarChoice.fromSeed(String seed) {
    final config = genConfig(seed: seed);
    return AvatarChoice(config: config, value: config.encode());
  }

  /// Presets are stored by name (`avatar_3`), which keeps the API value short
  /// and readable.
  factory AvatarChoice.preset(String id) =>
      AvatarChoice(config: NiceAvatarPresets.config(id), value: id);
}

/// The two ways to pick a ready-made avatar: a set generated from the user's
/// own account, then the shared preset catalogue.
class AvatarChoiceSections extends StatelessWidget {
  final List<String> recommendedSeeds;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  /// Horizontal strips instead of wrapping grids — for bottom sheets, where
  /// vertical space is the scarce thing.
  final bool compact;

  const AvatarChoiceSections({
    super.key,
    required this.recommendedSeeds,
    required this.selectedValue,
    required this.onSelected,
    this.compact = false,
  });

  List<AvatarChoice> get _recommended =>
      [for (final seed in recommendedSeeds) AvatarChoice.fromSeed(seed)];

  List<AvatarChoice> get _presets =>
      [for (final id in NiceAvatarPresets.ids) AvatarChoice.preset(id)];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Section(
          title: 'Recommended for you',
          subtitle: 'Generated from your account',
          choices: _recommended,
          selectedValue: selectedValue,
          onSelected: onSelected,
          compact: compact,
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'Presets',
          subtitle: 'A ready-made set anyone can pick from',
          choices: _presets,
          selectedValue: selectedValue,
          onSelected: onSelected,
          compact: compact,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AvatarChoice> choices;
  final String? selectedValue;
  final ValueChanged<String> onSelected;
  final bool compact;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.choices,
    required this.selectedValue,
    required this.onSelected,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: context.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (compact)
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: choices.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => AvatarChoiceTile(
                choice: choices[index],
                size: 64,
                isSelected: choices[index].value == selectedValue,
                onTap: () => onSelected(choices[index].value),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.base,
              crossAxisSpacing: AppSpacing.base,
            ),
            itemCount: choices.length,
            itemBuilder: (context, index) => LayoutBuilder(
              builder: (context, constraints) => AvatarChoiceTile(
                choice: choices[index],
                size: constraints.maxWidth,
                isSelected: choices[index].value == selectedValue,
                onTap: () => onSelected(choices[index].value),
              ),
            ),
          ),
      ],
    );
  }
}

class AvatarChoiceTile extends StatelessWidget {
  final AvatarChoice choice;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;

  const AvatarChoiceTile({
    super.key,
    required this.choice,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: NiceAvatar(
          config: choice.config,
          size: isSelected ? size - 10 : size - 6,
        ),
      ),
    );
  }
}

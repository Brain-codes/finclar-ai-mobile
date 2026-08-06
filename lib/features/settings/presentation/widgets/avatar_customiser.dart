import 'package:flutter/material.dart';
import 'package:nice_avatar/nice_avatar.dart';
import '../../../../core/theme/app_spacing.dart';
import 'avatar_color_row.dart';
import 'avatar_option_row.dart';

List<Color> _palette(List<String> hexes) =>
    [for (final hex in hexes) parseHexColor(hex)];

final _faceColors = _palette(AvatarOptions.faceColor);
final _hairColors = _palette(AvatarOptions.hairColor);
final _hatColors = _palette(AvatarOptions.hatColor);
final _shirtColors = _palette(AvatarOptions.shirtColor);
final _bgColors = _palette(AvatarOptions.bgColor);

/// Every part of the avatar, one row at a time. Emits a new config on each
/// change so the caller can drive the live preview.
class AvatarCustomiser extends StatelessWidget {
  final ResolvedAvatarConfig config;
  final ValueChanged<ResolvedAvatarConfig> onChanged;

  const AvatarCustomiser({
    super.key,
    required this.config,
    required this.onChanged,
  });

  /// Man and woman hairstyles are separate sets in the original — offering a
  /// womanLong cut under "man" produces shapes that don't line up with the face.
  List<AvatarOption<HairStyle>> get _hairStyles => switch (config.sex) {
        Sex.man => const [
            AvatarOption(HairStyle.normal, 'Normal'),
            AvatarOption(HairStyle.thick, 'Thick'),
            AvatarOption(HairStyle.mohawk, 'Mohawk'),
          ],
        Sex.woman => const [
            AvatarOption(HairStyle.normal, 'Normal'),
            AvatarOption(HairStyle.womanLong, 'Long'),
            AvatarOption(HairStyle.womanShort, 'Short'),
          ],
      };

  void _onSexChanged(Sex sex) {
    final styles = sex == Sex.man
        ? [HairStyle.normal, HairStyle.thick, HairStyle.mohawk]
        : [HairStyle.normal, HairStyle.womanLong, HairStyle.womanShort];
    onChanged(config.copyWith(
      sex: sex,
      hairStyle:
          styles.contains(config.hairStyle) ? config.hairStyle : HairStyle.normal,
      eyeBrowStyle: sex == Sex.man ? EyeBrowStyle.up : config.eyeBrowStyle,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      AvatarOptionRow<Sex>(
        label: 'Character',
        options: const [
          AvatarOption(Sex.man, 'Man'),
          AvatarOption(Sex.woman, 'Woman'),
        ],
        selected: config.sex,
        onSelectedChanged: _onSexChanged,
      ),
      AvatarColorRow(
        label: 'Skin tone',
        colors: _faceColors,
        selected: config.faceColor,
        onSelectedChanged: (c) => onChanged(config.copyWith(faceColor: c)),
      ),
      // A hat replaces the hair entirely, so offering hair options under one
      // would let the user change something they can't see.
      if (config.hatStyle == HatStyle.none) ...[
        AvatarOptionRow<HairStyle>(
          label: 'Hair',
          options: _hairStyles,
          selected: config.hairStyle,
          onSelectedChanged: (v) => onChanged(config.copyWith(hairStyle: v)),
        ),
        AvatarColorRow(
          label: 'Hair colour',
          colors: _hairColors,
          selected: config.hairColor,
          onSelectedChanged: (c) => onChanged(config.copyWith(hairColor: c)),
        ),
      ],
      AvatarOptionRow<HatStyle>(
        label: 'Hat',
        options: const [
          AvatarOption(HatStyle.none, 'None'),
          AvatarOption(HatStyle.beanie, 'Beanie'),
          AvatarOption(HatStyle.turban, 'Turban'),
        ],
        selected: config.hatStyle,
        onSelectedChanged: (v) => onChanged(config.copyWith(hatStyle: v)),
      ),
      if (config.hatStyle != HatStyle.none)
        AvatarColorRow(
          label: 'Hat colour',
          colors: _hatColors,
          selected: config.hatColor,
          onSelectedChanged: (c) => onChanged(config.copyWith(hatColor: c)),
        ),
      AvatarOptionRow<EyeStyle>(
        label: 'Eyes',
        options: const [
          AvatarOption(EyeStyle.oval, 'Oval'),
          AvatarOption(EyeStyle.circle, 'Circle'),
          AvatarOption(EyeStyle.smile, 'Smiling'),
        ],
        selected: config.eyeStyle,
        onSelectedChanged: (v) => onChanged(config.copyWith(eyeStyle: v)),
      ),
      AvatarOptionRow<EyeBrowStyle>(
        label: 'Eyebrows',
        options: const [
          AvatarOption(EyeBrowStyle.up, 'Natural'),
          AvatarOption(EyeBrowStyle.upWoman, 'Bold'),
        ],
        selected: config.eyeBrowStyle,
        onSelectedChanged: (v) => onChanged(config.copyWith(eyeBrowStyle: v)),
      ),
      AvatarOptionRow<GlassesStyle>(
        label: 'Glasses',
        options: const [
          AvatarOption(GlassesStyle.none, 'None'),
          AvatarOption(GlassesStyle.round, 'Round'),
          AvatarOption(GlassesStyle.square, 'Square'),
        ],
        selected: config.glassesStyle,
        onSelectedChanged: (v) => onChanged(config.copyWith(glassesStyle: v)),
      ),
      AvatarOptionRow<EarSize>(
        label: 'Ears',
        options: const [
          AvatarOption(EarSize.small, 'Small'),
          AvatarOption(EarSize.big, 'Big'),
        ],
        selected: config.earSize,
        onSelectedChanged: (v) => onChanged(config.copyWith(earSize: v)),
      ),
      AvatarOptionRow<NoseStyle>(
        label: 'Nose',
        options: const [
          AvatarOption(NoseStyle.short, 'Short'),
          AvatarOption(NoseStyle.long, 'Long'),
          AvatarOption(NoseStyle.round, 'Round'),
        ],
        selected: config.noseStyle,
        onSelectedChanged: (v) => onChanged(config.copyWith(noseStyle: v)),
      ),
      AvatarOptionRow<MouthStyle>(
        label: 'Mouth',
        options: const [
          AvatarOption(MouthStyle.smile, 'Smile'),
          AvatarOption(MouthStyle.laugh, 'Laugh'),
          AvatarOption(MouthStyle.peace, 'Calm'),
        ],
        selected: config.mouthStyle,
        onSelectedChanged: (v) => onChanged(config.copyWith(mouthStyle: v)),
      ),
      AvatarOptionRow<ShirtStyle>(
        label: 'Top',
        options: const [
          AvatarOption(ShirtStyle.short, 'Tee'),
          AvatarOption(ShirtStyle.hoody, 'Hoody'),
          AvatarOption(ShirtStyle.polo, 'Polo'),
        ],
        selected: config.shirtStyle,
        onSelectedChanged: (v) => onChanged(config.copyWith(shirtStyle: v)),
      ),
      AvatarColorRow(
        label: 'Top colour',
        colors: _shirtColors,
        selected: config.shirtColor,
        onSelectedChanged: (c) => onChanged(config.copyWith(shirtColor: c)),
      ),
      AvatarColorRow(
        label: 'Background',
        colors: _bgColors,
        selected: config.bgColor,
        onSelectedChanged: (c) =>
            onChanged(config.copyWith(bgColor: c, clearGradient: true)),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows) ...[
          row,
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

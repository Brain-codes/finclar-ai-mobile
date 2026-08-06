import 'package:flutter/material.dart';
import 'package:nice_avatar/nice_avatar.dart';

import 'app_avatar.dart';

/// The single place the app renders a user's `profile_icon`.
///
/// The stored string is either a preset id (`avatar_3`) or an encoded config
/// (`nav1.…`) — both resolve to the same generated face. When there is nothing
/// stored we fall back to initials so the UI never shows an empty circle.
class AppProfileAvatar extends StatelessWidget {
  final String? profileIcon;

  /// Used for the initials fallback, and as the seed when [seedWhenEmpty] is
  /// on — that way two users without an avatar still look different.
  ///
  /// Seeding deliberately uses the *name* rather than an account id, even
  /// where an id is available: it is the one identifier every call site has,
  /// so the same person gets the same face in the friends list, the group
  /// member list and the chat thread. The trade-off is that a username change
  /// reshuffles that person's generated face — which stops mattering as soon
  /// as the backend returns their real `profile_icon`.
  final String? name;

  final double size;
  final bool seedWhenEmpty;
  final BoxBorder? border;

  const AppProfileAvatar({
    super.key,
    required this.profileIcon,
    this.name,
    this.size = 40,
    this.seedWhenEmpty = false,
    this.border,
  });

  String? get _value {
    final icon = profileIcon?.trim();
    if (icon != null && icon.isNotEmpty) return icon;
    if (seedWhenEmpty) {
      final seed = name?.trim();
      if (seed != null && seed.isNotEmpty) return seed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final value = _value;
    if (value == null) {
      return AppAvatar(initials: name, size: size, border: border);
    }
    final avatar = NiceAvatar.fromString(value, size: size);
    if (border == null) return avatar;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: ClipOval(child: avatar),
    );
  }
}

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));
String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final String id;
  final String email;
  final String username;

  /// What the user asked to be called. Null until they set one.
  final String? preferredName;
  final String? profileIcon;
  final bool isActive;
  final bool isEmailVerified;
  final String defaultCurrency;
  final String createdAt;

  /// Backend-computed: [preferredName] when set, else [username]. Prefer this
  /// over [username] anywhere the app addresses the user.
  final String displayName;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.preferredName,
    this.profileIcon,
    required this.isActive,
    required this.isEmailVerified,
    required this.defaultCurrency,
    required this.createdAt,
    String? displayName,
  }) : displayName = (displayName != null && displayName.trim().isNotEmpty)
            ? displayName
            : ((preferredName != null && preferredName.trim().isNotEmpty)
                ? preferredName
                : username);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        username: json['username'] as String? ?? '',
        preferredName: json['preferred_name'] as String?,
        profileIcon: json['profile_icon'] as String?,
        isActive: json['is_active'] as bool? ?? false,
        isEmailVerified: json['is_email_verified'] as bool? ?? false,
        defaultCurrency: json['default_currency'] as String? ?? 'USD',
        createdAt: json['created_at'] as String? ?? '',
        displayName: json['display_name'] as String?,
      );

  bool get hasPreferredName => (preferredName?.trim().isNotEmpty ?? false);

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'preferred_name': preferredName,
        'profile_icon': profileIcon,
        'is_active': isActive,
        'is_email_verified': isEmailVerified,
        'default_currency': defaultCurrency,
        'created_at': createdAt,
        'display_name': displayName,
      };
}

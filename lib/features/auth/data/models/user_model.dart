import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));
String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final String id;
  final String email;
  final String username;
  final bool isActive;
  final bool isEmailVerified;
  final String defaultCurrency;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.isActive,
    required this.isEmailVerified,
    required this.defaultCurrency,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        username: json['username'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? false,
        isEmailVerified: json['is_email_verified'] as bool? ?? false,
        defaultCurrency: json['default_currency'] as String? ?? 'USD',
        createdAt: json['created_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'is_active': isActive,
        'is_email_verified': isEmailVerified,
        'default_currency': defaultCurrency,
        'created_at': createdAt,
      };
}

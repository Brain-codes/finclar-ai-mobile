import 'dart:convert';

TokenPairModel tokenPairModelFromJson(String str) =>
    TokenPairModel.fromJson(json.decode(str));
String tokenPairModelToJson(TokenPairModel data) => json.encode(data.toJson());

class TokenPairModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  TokenPairModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory TokenPairModel.fromJson(Map<String, dynamic> json) => TokenPairModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
      };
}

import 'dart:convert';

BankModel bankModelFromJson(String str) =>
    BankModel.fromJson(json.decode(str));
String bankModelToJson(BankModel data) => json.encode(data.toJson());

class BankModel {
  final String id;
  final String name;
  final String accountNumber;
  final String monoAccountId;

  BankModel({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.monoAccountId,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) => BankModel(
        id: json["id"] ?? '',
        name: json["name"] ?? '',
        accountNumber: json["account_number"] ?? '',
        monoAccountId: json["mono_account_id"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "account_number": accountNumber,
        "mono_account_id": monoAccountId,
      };

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    final visible = accountNumber.substring(accountNumber.length - 4);
    return '****$visible';
  }
}

class AvailableBankModel {
  final String id;
  final String name;
  final String code;
  final String? logoUrl;

  AvailableBankModel({
    required this.id,
    required this.name,
    required this.code,
    this.logoUrl,
  });

  factory AvailableBankModel.fromJson(Map<String, dynamic> json) =>
      AvailableBankModel(
        id: json["id"] ?? '',
        name: json["name"] ?? '',
        code: json["code"] ?? '',
        logoUrl: json["logo_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "logo_url": logoUrl,
      };
}

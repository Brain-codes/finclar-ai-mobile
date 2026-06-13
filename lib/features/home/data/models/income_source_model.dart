import 'dart:convert';

IncomeSourceModel incomeSourceModelFromJson(String str) =>
    IncomeSourceModel.fromJson(json.decode(str));
String incomeSourceModelToJson(IncomeSourceModel data) =>
    json.encode(data.toJson());

class IncomeSourceModel {
  final String id;
  final String name;
  final bool isDefault;

  const IncomeSourceModel({
    required this.id,
    required this.name,
    required this.isDefault,
  });

  factory IncomeSourceModel.fromJson(Map<String, dynamic> json) =>
      IncomeSourceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        isDefault: json['is_default'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_default': isDefault,
      };
}

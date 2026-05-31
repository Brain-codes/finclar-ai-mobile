import 'dart:convert';

List<CategoryModel> categoryModelListFromJson(String str) =>
    List<CategoryModel>.from(json.decode(str).map((x) => CategoryModel.fromJson(x)));

String categoryModelListToJson(List<CategoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryModel {
  final String id;
  final String name;
  final bool isDefault;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        isDefault: json['is_default'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_default': isDefault,
      };
}

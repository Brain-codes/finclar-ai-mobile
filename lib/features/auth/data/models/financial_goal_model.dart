class FinancialGoalModel {
  final String id;
  final String key;
  final String name;
  final String? description;
  final String? iconName;

  FinancialGoalModel({
    required this.id,
    required this.key,
    required this.name,
    this.description,
    this.iconName,
  });

  factory FinancialGoalModel.fromJson(Map<String, dynamic> json) =>
      FinancialGoalModel(
        id: json["id"],
        key: json["key"] ?? '',
        name: json["name"] ?? '',
        description: json["description"],
        iconName: json["icon_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "name": name,
        "description": description,
        "icon_name": iconName,
      };
}

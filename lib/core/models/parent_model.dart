import 'package:hive_flutter/hive_flutter.dart';

part 'parent_model.g.dart';

@HiveType(typeId: 3)
class ParentModel {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String famcode;
  @HiveField(2)
  final String mobile;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String relation;
  ParentModel({
    required this.name,
    required this.famcode,
    required this.mobile,
    required this.email,
    required this.relation,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) => ParentModel(
        name: json["name"] ?? "",
        famcode: json["famcode"] ?? "",
        mobile: json["mobile"] ?? "",
        email: json["email"] ?? "",
        relation: json["relation"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "famcode": famcode,
        "mobile": mobile,
        "email": email,
        "relation": relation,
      };
}

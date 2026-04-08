import 'package:hive/hive.dart';

part 'auth_model.g.dart';

@HiveType(typeId: 1)
class AuthModel {
  @HiveField(0)
  final String token;

  @HiveField(1)
  final String famcode;

  AuthModel(this.token, this.famcode);
}

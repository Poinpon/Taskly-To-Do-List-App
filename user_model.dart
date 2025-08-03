import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password;

  @HiveField(2)
  String role;

  UserModel({
    required this.username,
    required this.password,
    this.role = 'user',
  });
}

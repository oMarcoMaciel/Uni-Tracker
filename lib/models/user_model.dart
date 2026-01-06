import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String course;

  @HiveField(2)
  String university;

  @HiveField(3)
  String? profileImagePath;

  @HiveField(4) // <--- NOVO CAMPO
  String email;

  UserModel({
    required this.name,
    required this.course,
    required this.university,
    this.email = "", // Valor padrão para evitar erros
    this.profileImagePath,
  });
}
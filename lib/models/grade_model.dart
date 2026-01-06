import 'package:hive/hive.dart';

part 'grade_model.g.dart';

@HiveType(typeId: 2) // ID diferente do SubjectModel
class GradeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // Ex: "P1", "Trabalho"

  @HiveField(2)
  final double value; // A nota (Ex: 8.5)

  GradeModel({
    required this.id,
    required this.name,
    required this.value,
  });
}
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

  @HiveField(3) // <--- NOVO: Peso da nota
  final double weight;

  @HiveField(4) // <--- NOVO: Unidade (Ex: "Unidade 1")
  final String unit;

  GradeModel({
    required this.id,
    required this.name,
    required this.value,
    this.weight = 1.0, // Padrão é peso 1
    this.unit = 'Unidade 1', // Padrão é Unidade 1
  });
}
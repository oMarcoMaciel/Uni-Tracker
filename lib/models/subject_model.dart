import 'package:hive/hive.dart';
import 'grade_model.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 1)
class SubjectModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String professor;

  @HiveField(3)
  int faults;

  @HiveField(4)
  final int maxFaults;

  @HiveField(5)
  final int colorValue;

  @HiveField(6) // <--- CAMPO NOVO IMPORTANTE
  final String periodId; // ID do período ao qual essa matéria pertence

  @HiveField(7) // <--- NOVO CAMPO
  String? note; // Pode ser nulo se não tiver anotação

  @HiveField(8) // <--- NOVO CAMPO
  List<GradeModel> grades; // Lista de notas

  SubjectModel({
    required this.id,
    required this.periodId, // Adicionado aqui
    required this.name,
    required this.professor,
    this.faults = 0,
    required this.maxFaults,
    required this.colorValue,
    this.note, // <--- Adicionar no construtor
    List<GradeModel>? grades, // No construtor
  }) : grades = grades ?? []; // Se vier nulo, inicia lista vazia
}
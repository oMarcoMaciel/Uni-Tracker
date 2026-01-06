import 'package:hive/hive.dart';
import 'subject_model.dart';

part 'period_model.g.dart';

@HiveType(typeId: 0)
class PeriodModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // Ex: "2024.1"

  @HiveField(2)
  final bool isCurrent; // Se é o período atual

  @HiveField(3)
  List<SubjectModel> subjects; // Lista de matérias desse período

  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final DateTime endDate;

  PeriodModel({
    required this.id,
    required this.name,
    this.isCurrent = false,
    required this.subjects,
    required this.startDate, // Obrigatório agora
    required this.endDate,   // Obrigatório agora
  });
}
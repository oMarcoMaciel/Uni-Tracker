import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/period_model.dart';
import '../models/subject_model.dart';

class AcademicProvider extends ChangeNotifier {
  // Referência direta para a caixa do banco de dados
  final Box<PeriodModel> _box = Hive.box<PeriodModel>('periodsBox');

  // Lista que a tela vai ler
  List<PeriodModel> get periods => _box.values.toList();

  // Função para adicionar um NOVO período
  Future<void> addPeriod(String name, DateTime start, DateTime end, bool isCurrent) async {
    final newId = const Uuid().v4(); // Gera ID único
    
    // Se este for marcado como atual, desmarca os outros
    if (isCurrent) {
      _uncheckOtherCurrentPeriods();
    }

    final newPeriod = PeriodModel(
      id: newId,
      name: name,
      isCurrent: isCurrent,
      subjects: [], // Começa sem matérias
      startDate: start, // <--- Salvando data inicio
      endDate: end,     // <--- Salvando data fim
    );

    // Salva no banco
    await _box.put(newId, newPeriod);
    
    // Avisa a tela para atualizar
    notifyListeners(); 
  }

  // Função para deletar período
  Future<void> deletePeriod(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  // Função auxiliar para garantir que só existe um período "Atual"
  void _uncheckOtherCurrentPeriods() {
    for (var period in _box.values) {
      if (period.isCurrent) {
        // Cria uma cópia atualizada com isCurrent = false
        final updated = PeriodModel(
          id: period.id,
          name: period.name,
          isCurrent: false,
          subjects: period.subjects,
          startDate: period.startDate, // <--- CORREÇÃO AQUI: Repassando a data original
          endDate: period.endDate,     // <--- CORREÇÃO AQUI: Repassando a data original
        );
        _box.put(period.id, updated);
      }
    }
  }

  // --- FUNÇÕES DE MATÉRIAS (DISCIPLINAS) ---

  Future<void> addSubject(String periodId, SubjectModel subject) async {
    final period = _box.get(periodId);
    if (period != null) {
      // O Hive não detecta mudanças dentro de listas automaticamente,
      // então precisamos adicionar na lista e salvar o objeto pai (period) de novo.
      period.subjects.add(subject);
      period.save(); // Salva as alterações desse objeto específico
      notifyListeners();
    }
  }
}
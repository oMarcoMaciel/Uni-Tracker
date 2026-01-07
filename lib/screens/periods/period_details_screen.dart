import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // <--- Importante para ouvir o banco
import '../../core/theme/app_colors.dart';
import '../../models/period_model.dart';
import '../../models/subject_model.dart'; // <--- Import do modelo de matérias
import '../subject/add_subject_screen.dart';
import '../subject/subject_details_screen.dart';
import 'add_period_screen.dart'; // Import para edição de período

class PeriodDetailsScreen extends StatefulWidget {
  final PeriodModel period;

  const PeriodDetailsScreen({
    super.key,
    required this.period,
  });

  @override
  State<PeriodDetailsScreen> createState() => _PeriodDetailsScreenState();
}

class _PeriodDetailsScreenState extends State<PeriodDetailsScreen> {
  // Variável local para manter o período atualizado caso seja editado
  late PeriodModel _period;

  @override
  void initState() {
    super.initState();
    _period = widget.period;
  }

  // --- Lógica para excluir o período ---
  Future<void> _deletePeriod() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Excluir Período?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Isso apagará o período e todas as suas disciplinas e notas.\nEssa ação não pode ser desfeita.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir Tudo", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. Deletar Disciplinas associadas
      var subjectsBox = Hive.box<SubjectModel>('subjects');
      final subjectsToDelete = subjectsBox.values.where((s) => s.periodId == _period.id).toList();
      for (var subject in subjectsToDelete) {
        await subjectsBox.delete(subject.id);
      }

      // 2. Deletar o Período
      var periodsBox = Hive.box<PeriodModel>('periodsBox');
      await periodsBox.delete(_period.id);

      if (mounted) Navigator.pop(context); // Volta para a lista
    }
  }

  // --- Lógica para editar o período ---
  Future<void> _editPeriod() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPeriodScreen(periodToEdit: _period),
      ),
    );

    // Recarrega os dados do banco após voltar da edição
    var box = Hive.box<PeriodModel>('periodsBox');
    var updated = box.get(_period.id);
    if (updated != null) {
      setState(() {
        _period = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detalhes do Período",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            onPressed: _editPeriod,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: _deletePeriod,
          ),
        ],
      ),
      body: Stack(
        children: [
          // USANDO ValueListenableBuilder PARA OUVIR MUDANÇAS NO BANCO DE MATÉRIAS
          ValueListenableBuilder(
            valueListenable: Hive.box<SubjectModel>('subjects').listenable(),
            builder: (context, Box<SubjectModel> box, _) {
              
              // 1. Filtrar apenas as matérias deste período
              final subjects = box.values
                  .where((subject) => subject.periodId == _period.id)
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e Subtítulo
                    Text(
                      _period.name, // Usa a variável local _period
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ano Letivo ${_period.startDate.year}",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),

                    const SizedBox(height: 24),

                    // Card de Status
                    _buildStatusCard(subjects), 

                    const SizedBox(height: 32),

                    // Cabeçalho da Lista
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Disciplinas",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${subjects.length} Matérias", // <--- Contador dinâmico
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 2. LISTA DINÂMICA
                    if (subjects.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: subjects.map((subject) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSubjectItem(
                              context,
                              subject: subject, // Passamos o objeto inteiro agora
                            ),
                          );
                        }).toList(),
                      ),
                      
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),

          // Botão Flutuante
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSubjectScreen(
                        periodId: _period.id,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 24),
                label: const Text(
                  "Adicionar Disciplina",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget de Lista Vazia ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.library_books_outlined, size: 60, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "Nenhuma disciplina ainda",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

// --- CARD DE STATUS INTELIGENTE ---
  Widget _buildStatusCard(List<SubjectModel> subjects) {
    // 1. CÁLCULO DAS FALTAS CRÍTICAS
    // Alterado: Agora conta como crítica se tiver 13 ou mais faltas
    int criticalFaults = subjects.where((s) => s.faults >= 13).length;

    // 2. CÁLCULO DA MÉDIA GERAL DO SEMESTRE
    double totalAverage = 0;
    int subjectsWithGrades = 0;

    for (var subject in subjects) {
      if (subject.grades.isNotEmpty) {
        // Calcula a média dessa matéria
        // Nota: Assumindo que a lógica de cálculo de média está correta nos seus models
        // Se precisar de média ponderada, idealmente essa lógica estaria dentro do SubjectModel
        double subjectAvg = subject.grades.map((g) => g.value).reduce((a, b) => a + b) / subject.grades.length;
        totalAverage += subjectAvg;
        subjectsWithGrades++;
      }
    }

    // Se tiver pelo menos uma matéria com nota, faz a média geral. Senão, é 0.
    double semesterAverage = subjectsWithGrades > 0 ? totalAverage / subjectsWithGrades : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Resumo do Semestre",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Lado Esquerdo: Média Geral
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    semesterAverage == 0 ? "--" : semesterAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Média Geral",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              
              // Lado Direito: Matérias em Risco
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$criticalFaults",
                    style: TextStyle(
                      // Fica vermelho se houver qualquer matéria com >= 13 faltas
                      color: criticalFaults > 0 ? const Color(0xFFFF5252) : AppColors.primary, 
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text(
                        "Matérias Críticas",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

// --- Widget do Item da Matéria ---
  Widget _buildSubjectItem(BuildContext context, {required SubjectModel subject}) {
    
    // --- LÓGICA DE CORES DA BOLINHA (Atualizada) ---
    Color statusColor;

    if (subject.faults >= 16) {
      statusColor = const Color(0xFF757575); // Reprovado (Cinza Chumbo)
    } else if (subject.faults >= 13) {
      statusColor = const Color(0xFFFF5252); // Crítico (Vermelho)
    } else if (subject.faults >= 8) {
      statusColor = const Color(0xFFFFC107); // Atenção (Amarelo)
    } else {
      statusColor = AppColors.primary;       // Em dia (Verde)
    }
    // ------------------------------------------------

    final subjectColor = Color(subject.colorValue);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubjectDetailsScreen(subject: subject)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.book, color: subjectColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject.professor,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${subject.faults}/${subject.maxFaults}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
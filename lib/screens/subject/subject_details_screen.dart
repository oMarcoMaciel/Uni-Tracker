import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/subject_model.dart';
import '../../models/grade_model.dart';
import 'add_subject_screen.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final SubjectModel subject;

  const SubjectDetailsScreen({super.key, required this.subject});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  late SubjectModel _subject;
  late int _faltas;
  late TextEditingController _noteController;
  bool _isSavingNote = false;

  // Estado do Filtro
  String _selectedFilter = "Geral";

  final Color _greenColor = const Color(0xFF00E676);
  final Color _darkInput = const Color(0xFF1C211E);

  @override
  void initState() {
    super.initState();
    _subject = widget.subject;
    _faltas = _subject.faults;
    _noteController = TextEditingController(text: _subject.note ?? "");
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // --- HELPER: Calcula peso total de uma unidade ---
  double _getTotalWeightForUnit(String unitName) {
    return _subject.grades
        .where((g) => g.unit == unitName)
        .fold(0.0, (sum, g) => sum + g.weight);
  }

  // --- HELPER: Verifica se existe nota na Final ---
  GradeModel? _getFinalGrade() {
    try {
      return _subject.grades.firstWhere((g) => g.unit == 'Final');
    } catch (e) {
      return null;
    }
  }

  // --- HELPER: Verifica se deve mostrar a FINAL ---
  bool _shouldShowFinal() {
    double w1 = _getTotalWeightForUnit('Unidade 1');
    double w2 = _getTotalWeightForUnit('Unidade 2');
    
    // --- CORREÇÃO AQUI ---
    // 1. Separa as notas
    List<GradeModel> u1Grades = _subject.grades.where((g) => g.unit == 'Unidade 1').toList();
    List<GradeModel> u2Grades = _subject.grades.where((g) => g.unit == 'Unidade 2').toList();

    // 2. Calcula as médias individuais (cada uma divide por 10)
    double u1Avg = _calculateWeightedAverage(u1Grades);
    double u2Avg = _calculateWeightedAverage(u2Grades);

    // 3. Faz a média aritmética correta entre as unidades
    double semesterAvg = (u1Avg + u2Avg) / 2; 
    // No seu exemplo: (8.0 + 0.0) / 2 = 4.0. (4.0 < 7, então mostra a Final)

    // Pequena margem de erro para double
    bool u1Full = w1 >= 9.99;
    bool u2Full = w2 >= 9.99;

    return u1Full && u2Full && semesterAvg < 7.0;
  }
  
  // --- LÓGICA: CÁLCULO DE MÉDIA PONDERADA (Genérico) ---
  double _calculateWeightedAverage(List<GradeModel> grades) {
      if (grades.isEmpty) return 0.0;

      double weightedSum = 0;
      
      // Soma: Nota * Peso
      for (var grade in grades) {
        weightedSum += (grade.value * grade.weight);
      }

      return weightedSum / 10.0;
    }

// --- LÓGICA: CÁLCULO DA MÉDIA GERAL ---
  double _calculateGlobalAverage() {
    // 1. Separa as notas por unidade
    List<GradeModel> u1Grades = _subject.grades.where((g) => g.unit == 'Unidade 1').toList();
    List<GradeModel> u2Grades = _subject.grades.where((g) => g.unit == 'Unidade 2').toList();

    // 2. Calcula a média de cada unidade separadamente
    // (Lembrando: sua função _calculateWeightedAverage já divide por 10 para considerar o acumulado)
    double u1Avg = _calculateWeightedAverage(u1Grades); // Ex: (8*10)/10 = 8.0
    double u2Avg = _calculateWeightedAverage(u2Grades); // Ex: (10*5)/10 = 5.0

    // 3. Calcula a média do semestre (Média Aritmética das duas unidades)
    double semesterAvg = (u1Avg + u2Avg) / 2; 
    // No seu exemplo: (8.0 + 5.0) / 2 = 6.5

    // 4. Verifica se existe nota de Final
    GradeModel? finalGrade = _getFinalGrade();

    if (finalGrade != null) {
      // LÓGICA DA FINAL: (Média Semestre + Nota Final) / 2
      return (semesterAvg + finalGrade.value) / 2;
    }

    return semesterAvg;
  }

  // --- ATUALIZAR FALTAS ---
  Future<void> _updateFaults(int newValue) async {
    if (newValue < 0) return;
    setState(() => _faltas = newValue);
    var box = Hive.box<SubjectModel>('subjects');
    _subject.faults = newValue;
    await box.put(_subject.id, _subject);
  }

  // --- SALVAR ANOTAÇÃO ---
  Future<void> _saveNote() async {
    setState(() => _isSavingNote = true);
    var box = Hive.box<SubjectModel>('subjects');
    _subject.note = _noteController.text;
    await box.put(_subject.id, _subject);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isSavingNote = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Anotação salva!")));
      FocusScope.of(context).unfocus();
    }
  }

  // --- EXCLUIR DISCIPLINA ---
  Future<void> _deleteSubject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Excluir Disciplina?",
            style: TextStyle(color: Colors.white)),
        content: const Text("Tudo será apagado permanentemente.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      var box = Hive.box<SubjectModel>('subjects');
      await box.delete(_subject.id);
      if (mounted) Navigator.pop(context);
    }
  }

  // --- EDITAR DISCIPLINA ---
  Future<void> _editSubject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSubjectScreen(
          periodId: _subject.periodId,
          subjectToEdit: _subject,
        ),
      ),
    );
    var box = Hive.box<SubjectModel>('subjects');
    var updatedSubject = box.get(_subject.id);
    if (updatedSubject != null) {
      setState(() {
        _subject = updatedSubject;
        _faltas = updatedSubject.faults;
        _noteController.text = updatedSubject.note ?? "";
      });
    }
  }

// --- MODAL DE ADICIONAR NOTA ---
  void _showAddGradeDialog() {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    final weightController = TextEditingController();

    // Lista dinâmica
    final List<String> units = ['Unidade 1', 'Unidade 2'];
    
    if (_shouldShowFinal() || _getFinalGrade() != null) {
       if (!units.contains('Final')) units.add('Final');
    }

    String selectedUnit = units.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateModal) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Nova Avaliação",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // DROPDOWN UNIDADE
                  const Text("Selecione a Unidade",
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _darkInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUnit,
                        dropdownColor: AppColors.surface,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey),
                        style: const TextStyle(color: Colors.white),
                        items: units.map((String unit) {
                          return DropdownMenuItem<String>(
                              value: unit, child: Text(unit));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setStateModal(() => selectedUnit = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NOME
                  const Text("Nome da Avaliação",
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _darkInput,
                      hintText: "Ex: Prova 1",
                      hintStyle: const TextStyle(color: Colors.white24),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white10)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // PESO
                  if (selectedUnit != 'Final') ...[
                    const Text("Peso (Máx total: 10.0)",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _darkInput,
                        hintText: "Padrão: 1.0",
                        hintStyle: const TextStyle(color: Colors.white24),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white10)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // NOTA OBTIDA
                  const Text("Nota Obtida (2 casas decimais)",
                      style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: gradeController,
                    keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    inputFormatters: [
                      // --- MUDANÇA 1: Removi o _MaxValueTextInputFormatter ---
                      // Deixei apenas a permissão de números e ponto/vírgula
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _darkInput,
                      hintText: "Ex: 6.75",
                      hintStyle: const TextStyle(color: Colors.white24),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white10)),
                    ),
                    ),
                  const SizedBox(height: 24),
                  
                  // BOTÃO SALVAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (nameController.text.isNotEmpty) {
                          // Conversões
                          double finalWeight = 1.0;
                          
                          if (selectedUnit == 'Final') {
                            finalWeight = 10.0; 
                          } else {
                             if (weightController.text.isNotEmpty) {
                              finalWeight = double.tryParse(weightController.text.replaceAll(',', '.')) ?? 1.0;
                             }
                          }

                          double finalValue = 0.0;
                          if (gradeController.text.isNotEmpty) {
                            finalValue = double.tryParse(gradeController.text.replaceAll(',', '.')) ?? 0.0;
                          }

                          // --- MUDANÇA 2: Validação de Nota Máxima ---
                          if (finalValue > 10.0) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Erro: A nota não pode ser maior que 10.00"),
                                ),
                              );
                            }
                            return; // Para a execução e não salva
                          }
                          // -------------------------------------------

                          // Validação de Peso Máximo (U1 e U2)
                          if (selectedUnit != 'Final') {
                            double currentUnitWeight = _getTotalWeightForUnit(selectedUnit);

                            if (currentUnitWeight + finalWeight > 10.0) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        "Erro: O peso total da $selectedUnit não pode passar de 10.0 (Atual: $currentUnitWeight)"),
                                  ),
                                );
                              }
                              return; 
                            }
                          } else {
                            // Validação para Final
                            if (_getFinalGrade() != null) {
                               if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text("Erro: Já existe uma nota de Final cadastrada."),
                                  ),
                                );
                              }
                              return;
                            }
                          }

                          final newGrade = GradeModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameController.text,
                            value: finalValue,
                            weight: finalWeight,
                            unit: selectedUnit,
                          );

                          var box = Hive.box<SubjectModel>('subjects');
                          _subject.grades.add(newGrade);
                          await box.put(_subject.id, _subject);
                          setState(() {});
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _greenColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Salvar Avaliação",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  List<GradeModel> _getFilteredGrades() {
    if (_selectedFilter == "Geral") return _subject.grades;
    return _subject.grades.where((g) => g.unit == _selectedFilter).toList();
  }

@override
  Widget build(BuildContext context) {
    // 1. Lista para exibir
    final displayedGrades = _getFilteredGrades();

    // 2. Média para exibir
    double averageToShow = 0.0;

    // --- CORREÇÃO AQUI: Cálculo correto da Média do Semestre (separando unidades) ---
    List<GradeModel> u1Grades =
        _subject.grades.where((g) => g.unit == 'Unidade 1').toList();
    List<GradeModel> u2Grades =
        _subject.grades.where((g) => g.unit == 'Unidade 2').toList();

    double u1Avg = _calculateWeightedAverage(u1Grades);
    double u2Avg = _calculateWeightedAverage(u2Grades);

    // Média Aritmética entre as duas unidades
    double semesterAvg = (u1Avg + u2Avg) / 2;
    // -----------------------------------------------------------------------------

    if (_selectedFilter == "Geral") {
      averageToShow = _calculateGlobalAverage();
    } else if (_selectedFilter == "Final") {
      // VERIFICAÇÃO: Já existe nota da final lançada?
      var finalGrade = _getFinalGrade();

      if (finalGrade != null) {
        // CASO 1: Já tem nota. O cálculo é: (Média Semestre + Nota Final) / 2
        averageToShow = (semesterAvg + finalGrade.value) / 2;
      } else {
        // CASO 2: Ainda não tem nota. Mostra quanto o aluno já acumulou (Média Semestre / 2)
        averageToShow = semesterAvg / 2;
      }
    } else {
      // Filtra apenas as notas da unidade selecionada
      List<GradeModel> unitGrades =
          _subject.grades.where((g) => g.unit == _selectedFilter).toList();
      averageToShow = _calculateWeightedAverage(unitGrades);
    }

    // ALTERAÇÃO AQUI: Envolvi o Scaffold com GestureDetector para fechar o teclado
    return GestureDetector(
      onTap: () {
        // Remove o foco de qualquer campo de texto (fecha o teclado)
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text("Detalhes da Disciplina",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: _editSubject),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                onPressed: _deleteSubject),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_subject.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Text(_subject.professor,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
      
              const SizedBox(height: 24),
              _buildAttendanceCard(),
              const SizedBox(height: 32),
      
              const Text("Avaliações",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
      
              // CARD DE MÉDIA
              _buildSummaryCard(averageToShow, _selectedFilter),
      
              const SizedBox(height: 20),
      
              // FILTROS
              Container(
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    _buildFilterTab("Geral"),
                    _buildFilterTab("Unidade 1"),
                    _buildFilterTab("Unidade 2"),
                    // Só mostra a aba Final se ela existir ou for necessária
                    if (_shouldShowFinal() || _getFinalGrade() != null)
                      _buildFilterTab("Final"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
      
              // LISTA
              if (displayedGrades.isEmpty)
                _buildEmptyGradeState()
              else
                Column(
                  children: displayedGrades.map((grade) {
                    return Dismissible(
                      key: Key(grade.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.withOpacity(0.8),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        var box = Hive.box<SubjectModel>('subjects');
                        _subject.grades.remove(grade);
                        await box.put(_subject.id, _subject);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAssessmentItem(grade),
                      ),
                    );
                  }).toList(),
                ),
      
              const SizedBox(height: 12),
      
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _showAddGradeDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: _greenColor.withOpacity(0.5))),
                  ),
                  icon: Icon(Icons.add, color: _greenColor),
                  label: Text("Adicionar Nova Avaliação",
                      style: TextStyle(
                          color: _greenColor, fontWeight: FontWeight.bold)),
                ),
              ),
      
              const SizedBox(height: 32),
      
              // ANOTAÇÕES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Anotações",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _saveNote,
                    icon: _isSavingNote
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 24),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _noteController,
                      maxLines: null,
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: "Digite suas anotações aqui...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title) {
    bool isSelected = _selectedFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = title;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _greenColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double average, String filterName) {

// --- LÓGICA DE APROVAÇÃO DINÂMICA ---
    bool hasFinal = _getFinalGrade() != null;
    double targetScore = 7.0; // Padrão é 7

    // Se estiver na aba "Final", a meta EXPLICITAMENTE vira 5.0
    if (filterName == "Final") {
      targetScore = 5.0;
    } else if (hasFinal && filterName == "Geral") {
      // Se estiver no Geral e já tiver feito final, a meta global também é 5
      targetScore = 5.0;
    }

    bool aprovado = average >= targetScore;
    double progress = average / 10.0;
    if (progress > 1) progress = 1;

    String label = filterName == "Geral" ? "Média Geral" : "Média $filterName";
    
    // Ajuste do texto do label se estiver em final
    if (filterName == "Geral" && hasFinal) {
       label = "Média Final (Pós-Prova)";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        // EXIGÊNCIA: 2 casas decimais (ex: 6.75)
                        TextSpan(
                            text: average.toStringAsFixed(2),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: " / 10.0",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: aprovado
                      ? _greenColor.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(aprovado ? Icons.check_circle : Icons.warning,
                        color: aprovado ? _greenColor : Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(aprovado ? "Aprovado" : "Atenção",
                        style: TextStyle(
                            color: aprovado ? _greenColor : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4)),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: _greenColor,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("0", style: TextStyle(color: Colors.white24, fontSize: 10)),
              Text("META: $targetScore",
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const Text("10",
                  style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAssessmentItem(GradeModel grade) {
    bool isProva = grade.name.toLowerCase().contains("prova") ||
        grade.name.toLowerCase().contains("p");
    
    // Tratamento visual para a Final
    bool isFinal = grade.unit == 'Final';
    
    Color tagColor = isFinal ? Colors.orange : (isProva ? Colors.blue : Colors.purple);
    String tagText = isFinal ? "EXAME FINAL" : (isProva ? "PROVA" : "TRABALHO");
    String unidadeText = grade.unit.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(tagText,
                              style: TextStyle(
                                  color: tagColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(unidadeText,
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(grade.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Se for Final, não mostra peso pois não usamos no calculo
                        if (!isFinal)
                          Row(
                            children: [
                              const Icon(Icons.scale,
                                  color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text("Peso: ${grade.weight}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          )
                        else 
                           const Text("-", style: TextStyle(color: Colors.white10)), // Espaço vazio para manter layout

                        Row(
                          children: [
                            const Text("NOTA OBTIDA",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Text(
                                // EXIGÊNCIA: 2 casas decimais aqui também
                                grade.value.toStringAsFixed(2),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGradeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text("Nenhuma avaliação encontrada.",
            style: TextStyle(color: Colors.white.withOpacity(0.3))),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    double progress = _faltas / _subject.maxFaults;
    if (progress > 1.0) progress = 1.0;
    bool isCritical = _faltas >= _subject.maxFaults;
    Color statusColor = isCritical ? const Color(0xFFFF5252) : AppColors.primary;
    String statusText = isCritical ? "CRÍTICO" : "EM DIA";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.calendar_today,
                        color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text("Controle de Faltas",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Utilizadas", style: TextStyle(color: Colors.white)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: "$_faltas",
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    TextSpan(
                        text: " / ${_subject.maxFaults} permitidas",
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black26,
                color: statusColor,
                minHeight: 8),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildControlButton(Icons.remove, () => _updateFaults(_faltas - 1)),
              const SizedBox(width: 12),
              _buildControlButton(Icons.add, () => _updateFaults(_faltas + 1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: icon == Icons.add
                ? AppColors.primary
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon,
            color: icon == Icons.add ? Colors.black : Colors.white),
      ),
    );
  }
}

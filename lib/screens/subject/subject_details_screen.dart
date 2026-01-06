import 'package:flutter/material.dart';
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
  // Variável local para manter os dados atualizados
  late SubjectModel _subject; 
  
  late int _faltas;
  late TextEditingController _noteController;
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    // Inicializa com os dados recebidos, mas permite alteração depois
    _subject = widget.subject; 
    _faltas = _subject.faults;
    _noteController = TextEditingController(text: _subject.note ?? "");
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // --- LÓGICA 1: ATUALIZAR FALTAS ---
  Future<void> _updateFaults(int newValue) async {
    if (newValue < 0) return;
    
    setState(() => _faltas = newValue);
    
    var box = Hive.box<SubjectModel>('subjects');
    _subject.faults = newValue; // Atualiza a variável local
    await box.put(_subject.id, _subject);
  }

  // --- LÓGICA 2: SALVAR ANOTAÇÃO ---
  Future<void> _saveNote() async {
    setState(() => _isSavingNote = true);
    
    var box = Hive.box<SubjectModel>('subjects');
    _subject.note = _noteController.text; // Atualiza a variável local
    await box.put(_subject.id, _subject);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() => _isSavingNote = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anotação salva!")));
      FocusScope.of(context).unfocus();
    }
  }

  // --- LÓGICA 3: EXCLUIR DISCIPLINA ---
  Future<void> _deleteSubject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Excluir Disciplina?", style: TextStyle(color: Colors.white)),
        content: const Text("Essa ação apagará todas as notas e anotações desta matéria.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      var box = Hive.box<SubjectModel>('subjects');
      await box.delete(_subject.id);
      if (mounted) Navigator.pop(context); 
    }
  }

  // --- LÓGICA 4: EDITAR DISCIPLINA (CORRIGIDA) ---
  Future<void> _editSubject() async {
    // 1. Vai para a tela de edição
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSubjectScreen(
          periodId: _subject.periodId,
          subjectToEdit: _subject, 
        ),
      ),
    );

    // 2. Quando voltar, recarrega os dados do banco!
    var box = Hive.box<SubjectModel>('subjects');
    var updatedSubject = box.get(_subject.id); // Pega a versão nova do banco

    if (updatedSubject != null) {
      setState(() {
        _subject = updatedSubject; // Atualiza a variável principal
        
        // Sincroniza os controladores visuais também
        _faltas = updatedSubject.faults;
        _noteController.text = updatedSubject.note ?? "";
      });
    }
  }

  // --- LÓGICA 5: ADICIONAR NOTA ---
  void _showAddGradeDialog() {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Nova Avaliação", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Nome (Ex: P1)", hintStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: gradeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Nota (Ex: 8.5)", hintStyle: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && gradeController.text.isNotEmpty) {
                final double? value = double.tryParse(gradeController.text.replaceAll(',', '.'));
                if (value != null) {
                  final newGrade = GradeModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    value: value,
                  );
                  var box = Hive.box<SubjectModel>('subjects');
                  _subject.grades.add(newGrade); // Usa _subject
                  await box.put(_subject.id, _subject);
                  setState(() {});
                  if(mounted) Navigator.pop(context);
                }
              }
            },
            child: const Text("Adicionar", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // --- CÁLCULO MÉDIA ---
  double _calculateAverage() {
    if (_subject.grades.isEmpty) return 0.0;
    double sum = 0;
    for (var grade in _subject.grades) sum += grade.value;
    return sum / _subject.grades.length;
  }

  @override
  Widget build(BuildContext context) {
    double average = _calculateAverage();

    // OBS: Troquei todas as chamadas 'widget.subject' por '_subject' daqui para baixo
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detalhes da Disciplina",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            onPressed: _editSubject,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: _deleteSubject,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CABEÇALHO
            Text(
              _subject.name, // Usa _subject
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 4),
                Text(_subject.professor, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 4),
                const Text("--:--", style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),

            const SizedBox(height: 24),

            // 2. CONTROLE DE FALTAS
            _buildAttendanceCard(),

            const SizedBox(height: 32),

            // 3. AVALIAÇÕES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Avaliações", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                if (_subject.grades.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: average >= 7 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Média: ${average.toStringAsFixed(1)}",
                      style: TextStyle(color: average >= 7 ? AppColors.primary : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_subject.grades.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text("Nenhuma nota registrada.", style: TextStyle(color: Colors.white.withOpacity(0.5))),
              )
            else
              Column(
                children: _subject.grades.map((grade) {
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
            
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.02),
              ),
              child: TextButton.icon(
                onPressed: _showAddGradeDialog,
                icon: const Icon(Icons.add_circle_outline, color: AppColors.textSecondary),
                label: const Text("Adicionar Avaliação", style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),

            const SizedBox(height: 32),

            // 4. ANOTAÇÕES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Anotações", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _saveNote,
                  icon: _isSavingNote
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _noteController,
                    maxLines: null, 
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                    decoration: const InputDecoration(
                      hintText: "Digite suas anotações aqui... Ex: Estudar capítulo 4 para a próxima aula.",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Toque no check acima para salvar", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      Icon(Icons.edit_note, color: AppColors.primary.withOpacity(0.5), size: 18),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DO CARD DE PRESENÇA ---
  Widget _buildAttendanceCard() {
    double progress = _faltas / _subject.maxFaults; // Usa _subject
    if (progress > 1.0) progress = 1.0;
    
    bool isCritical = _faltas >= _subject.maxFaults;
    Color statusColor = isCritical ? const Color(0xFFFF5252) : AppColors.primary;
    String statusText = isCritical ? "CRÍTICO" : "EM DIA";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_today, color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text("Controle de Faltas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
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
                    TextSpan(text: "$_faltas", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    TextSpan(text: " / ${_subject.maxFaults} permitidas", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
              minHeight: 8,
            ),
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
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: icon == Icons.add ? AppColors.primary : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: icon == Icons.add ? Colors.black : Colors.white),
      ),
    );
  }

  Widget _buildAssessmentItem(GradeModel grade) {
    Color color = grade.value >= 7 ? Colors.blue : Colors.orange;
    if (grade.value < 5) color = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              grade.name.length > 2 ? grade.name.substring(0, 2).toUpperCase() : grade.name.toUpperCase(), 
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(grade.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Text("Avaliação", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(grade.value.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
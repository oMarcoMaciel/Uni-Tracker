import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/subject_model.dart';

class AddSubjectScreen extends StatefulWidget {
  final String periodId;
  final SubjectModel? subjectToEdit; // <--- Novo: Aceita uma matéria para editar

  const AddSubjectScreen({
    super.key,
    required this.periodId,
    this.subjectToEdit, // Se for nulo = Criação. Se tiver dados = Edição.
  });

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _nameController = TextEditingController();
  final _professorController = TextEditingController();
  
  int _limitFaltas = 15;
  Color _selectedColor = const Color(0xFF00E676); // Verde neon padrão

  final List<Color> _colors = [
    const Color(0xFF00E676), // Verde
    const Color(0xFF2979FF), // Azul
    const Color(0xFFD500F9), // Roxo
    const Color(0xFFFF9100), // Laranja
    const Color(0xFFFF1744), // Vermelho
    const Color(0xFF1DE9B6), // Turquesa
  ];

  @override
  void initState() {
    super.initState();
    // SE FOR MODO EDIÇÃO, PREENCHE OS CAMPOS
    if (widget.subjectToEdit != null) {
      _nameController.text = widget.subjectToEdit!.name;
      _professorController.text = widget.subjectToEdit!.professor;
      _limitFaltas = widget.subjectToEdit!.maxFaults;
      _selectedColor = Color(widget.subjectToEdit!.colorValue);
    }
  }

  // --- FUNÇÃO PARA SALVAR (CRIAR OU ATUALIZAR) ---
  Future<void> _saveSubject() async {
    // 1. Validação básica
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite o nome da matéria.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Abrir a caixa do Hive
    var box = await Hive.openBox<SubjectModel>('subjects');

    if (widget.subjectToEdit != null) {
      // --- CASO 1: EDITAR ---
      // Criamos um novo objeto com os dados novos, mas MANTENDO o ID e dados históricos (notas/faltas)
      final updatedSubject = SubjectModel(
        id: widget.subjectToEdit!.id, // IMPORTANTE: Mesmo ID
        periodId: widget.periodId,
        name: _nameController.text,
        professor: _professorController.text.isNotEmpty ? _professorController.text : "Não informado",
        faults: widget.subjectToEdit!.faults, // Mantém faltas atuais
        maxFaults: _limitFaltas,
        colorValue: _selectedColor.value,
        note: widget.subjectToEdit!.note, // Mantém a anotação antiga
        grades: widget.subjectToEdit!.grades, // Mantém as notas antigas
      );

      await box.put(updatedSubject.id, updatedSubject);
    } else {
      // --- CASO 2: CRIAR NOVO ---
      final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final newSubject = SubjectModel(
        id: uniqueId,
        periodId: widget.periodId,
        name: _nameController.text,
        professor: _professorController.text.isNotEmpty ? _professorController.text : "Não informado",
        faults: 0,
        maxFaults: _limitFaltas,
        colorValue: _selectedColor.value,
      );

      await box.put(uniqueId, newSubject);
    }

    // 6. Fechar a tela
    if (mounted) {
      Navigator.pop(context, true); // Retorna true para atualizar a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se é edição para mudar o título
    final isEditing = widget.subjectToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Editar Disciplina" : "Adicionar Disciplina", // Título Dinâmico
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveSubject,
            child: const Text(
              "Salvar",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("INFORMAÇÕES BÁSICAS", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildLabel("Nome da Matéria"),
            _buildInput(controller: _nameController, hint: "Ex: Cálculo I", icon: Icons.menu_book),
            
            const SizedBox(height: 16),
            
            _buildLabel("Nome do Professor"),
            _buildInput(controller: _professorController, hint: "Ex: Dr. Silva", icon: Icons.person),
            
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),

            const Text("DETALHES ACADÊMICOS", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildLabel("Limite de Faltas"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCounterButton(icon: Icons.remove, onTap: () {
                    if (_limitFaltas > 0) setState(() => _limitFaltas--);
                  }),
                  Text(
                    "$_limitFaltas",
                    style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  _buildCounterButton(icon: Icons.add, onTap: () {
                    setState(() => _limitFaltas++);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),

            const Text("PERSONALIZAÇÃO", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildLabel("Cor da Etiqueta"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isSelected ? [
                        BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)
                      ] : [],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveSubject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text("Salvar Disciplina", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
             Center(
               child: TextButton(
                 onPressed: () => Navigator.pop(context),
                 child: const Text("Cancelar", style: TextStyle(color: AppColors.textSecondary)),
               ),
             )
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCounterButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}
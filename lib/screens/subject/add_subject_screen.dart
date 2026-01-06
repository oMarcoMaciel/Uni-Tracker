import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  int _limitFaltas = 15; // Valor inicial do print
  Color _selectedColor = const Color(0xFF00E676); // Verde neon padrão

  // Lista de cores disponíveis para a etiqueta
  final List<Color> _colors = [
    const Color(0xFF00E676), // Verde
    const Color(0xFF2979FF), // Azul
    const Color(0xFFD500F9), // Roxo
    const Color(0xFFFF9100), // Laranja
    const Color(0xFFFF1744), // Vermelho
    const Color(0xFF1DE9B6), // Turquesa
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Adicionar Disciplina",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Lógica de salvar virá depois
              Navigator.pop(context); 
            },
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
            
            // Input Nome da Matéria
            _buildLabel("Nome da Matéria"),
            _buildInput(hint: "Ex: Cálculo I", icon: Icons.menu_book),
            
            const SizedBox(height: 16),
            
            // Input Nome do Professor
            _buildLabel("Nome do Professor"),
            _buildInput(hint: "Ex: Dr. Silva", icon: Icons.person),
            
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),

            const Text("DETALHES ACADÊMICOS", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Contador de Faltas
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

            // Seletor de Cores
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

            // Botão Salvar Principal
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                   Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black, // Texto preto no botão verde
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

  Widget _buildInput({required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
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
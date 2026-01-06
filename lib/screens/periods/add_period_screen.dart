import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AddPeriodScreen extends StatefulWidget {
  const AddPeriodScreen({super.key});

  @override
  State<AddPeriodScreen> createState() => _AddPeriodScreenState();
}

class _AddPeriodScreenState extends State<AddPeriodScreen> {
  bool _isCurrentPeriod = false;
  DateTime? _startDate;
  DateTime? _endDate;

  // Função auxiliar para formatar data (Ex: 12 Fev 2024)
  String _formatDate(DateTime date) {
    // Para simplificar, vamos formatar na mão.
    // Em produção usariamos o pacote 'intl'.
    List<String> months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  // Função para abrir o calendário
  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Customiza as cores do calendário para ficar Dark
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
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
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: AppColors.textSecondary)),
        ),
        title: const Text("Novo Período", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Salvar (Mock)
            child: const Text("Salvar", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nome do Período"),
                  _buildInput(hint: "Ex: 2024.1, Semestre 1", icon: Icons.edit),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 4),
                    child: Text("Utilize um nome curto para fácil identificação.", 
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildLabel("Duração"),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildDateItem(
                          title: "Data de Início",
                          icon: Icons.calendar_today,
                          date: _startDate,
                          onTap: () => _selectDate(true),
                        ),
                        const Divider(height: 1, color: Colors.white10, indent: 56),
                        _buildDateItem(
                          title: "Data de Fim",
                          icon: Icons.event,
                          date: _endDate,
                          onTap: () => _selectDate(false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildLabel("Preferências"),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: AppColors.textSecondary, size: 20),
                      ),
                      title: const Text("Período Atual", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Definir como semestre ativo", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      trailing: Switch(
                        value: _isCurrentPeriod,
                        activeColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withOpacity(0.3),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[800],
                        onChanged: (val) => setState(() => _isCurrentPeriod = val),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botão Inferior Fixo
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text("Salvar Período", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInput({required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          suffixIcon: Icon(icon, color: Colors.grey[600], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildDateItem({required String title, required IconData icon, DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ),
            if (date != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDate(date),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              )
            else
              Row(
                children: const [
                  Text("Selecionar", style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
                ],
              )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/period_model.dart';

class AddPeriodScreen extends StatefulWidget {
  final PeriodModel? periodToEdit;

  const AddPeriodScreen({super.key, this.periodToEdit});

  @override
  State<AddPeriodScreen> createState() => _AddPeriodScreenState();
}

class _AddPeriodScreenState extends State<AddPeriodScreen> {
  final _nameController = TextEditingController();
  // 1. ADICIONADO: Um nó de foco para controlar o campo manualmente
  final _nameFocusNode = FocusNode();
  
  bool _isCurrentPeriod = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.periodToEdit != null) {
      _nameController.text = widget.periodToEdit!.name;
      _startDate = widget.periodToEdit!.startDate;
      _endDate = widget.periodToEdit!.endDate;
      _isCurrentPeriod = widget.periodToEdit!.isCurrent;
    }
  }

  // 2. ADICIONADO: Sempre descartar o FocusNode para não vazar memória
  @override
  void dispose() {
    _nameFocusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    List<String> months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Future<void> _selectDate(bool isStart) async {
    // 3. ALTERADO: Remove o foco explicitamente
    _nameFocusNode.unfocus();
    
    // TRUQUE: Espera 100ms para o teclado baixar totalmente antes de abrir o modal.
    // Isso impede que o Flutter "lembre" que o teclado estava aberto.
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
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

  Future<void> _savePeriod() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, digite um nome.')));
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecione as datas.')));
      return;
    }

    var box = await Hive.openBox<PeriodModel>('periodsBox');

    if (_isCurrentPeriod) {
      for (var period in box.values) {
        if (period.isCurrent && period.id != widget.periodToEdit?.id) {
          final deactivatedPeriod = PeriodModel(
            id: period.id,
            name: period.name,
            startDate: period.startDate,
            endDate: period.endDate,
            subjects: period.subjects,
            isCurrent: false,
          );
          await box.put(period.id, deactivatedPeriod);
        }
      }
    }

    if (widget.periodToEdit != null) {
      final updatedPeriod = PeriodModel(
        id: widget.periodToEdit!.id,
        name: _nameController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        subjects: widget.periodToEdit!.subjects,
        isCurrent: _isCurrentPeriod,
      );
      await box.put(updatedPeriod.id, updatedPeriod);
    } else {
      final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final newPeriod = PeriodModel(
        id: uniqueId,
        name: _nameController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        subjects: [],
        isCurrent: _isCurrentPeriod,
      );
      await box.put(uniqueId, newPeriod);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.periodToEdit != null;

    return GestureDetector(
      // Fecha o teclado ao tocar fora
      onTap: () => _nameFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 100,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar",
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          title: Text(isEditing ? "Editar Período" : "Novo Período",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _savePeriod,
              child: const Text("Salvar",
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16)),
                      child: TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode, // 4. VINCULADO AQUI
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Ex: 2024.1, Semestre 1",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          suffixIcon: Icon(Icons.edit,
                              color: Colors.grey[600], size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                        ),
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                            "Utilize um nome curto para fácil identificação.",
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12))),
                    const SizedBox(height: 32),
                    _buildLabel("Duração"),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _buildDateItem(
                              title: "Data de Início",
                              icon: Icons.calendar_today,
                              date: _startDate,
                              onTap: () => _selectDate(true)),
                          const Divider(
                              height: 1, color: Colors.white10, indent: 56),
                          _buildDateItem(
                              title: "Data de Fim",
                              icon: Icons.event,
                              date: _endDate,
                              onTap: () => _selectDate(false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLabel("Preferências"),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.verified,
                              color: AppColors.textSecondary, size: 20),
                        ),
                        title: const Text("Período Atual",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: const Text("Definir como semestre ativo",
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        trailing: Switch(
                          value: _isCurrentPeriod,
                          activeColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withOpacity(0.3),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey[800],
                          onChanged: (val) =>
                              setState(() => _isCurrentPeriod = val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _savePeriod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Salvar Período",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDateItem(
      {required String title,
      required IconData icon,
      DateTime? date,
      required VoidCallback onTap}) {
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
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500))),
            if (date != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_formatDate(date),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              )
            else
              Row(
                children: const [
                  Text("Selecionar",
                      style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right,
                      color: AppColors.textSecondary, size: 16),
                ],
              )
          ],
        ),
      ),
    );
  }
}
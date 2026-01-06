import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Importante
import '../../core/theme/app_colors.dart';
import '../../providers/academic_provider.dart';
import '../../models/period_model.dart';
import 'add_period_screen.dart';
import 'period_details_screen.dart';

class PeriodsScreen extends StatelessWidget {
  const PeriodsScreen({super.key});

  // Função auxiliar para formatar datas na lista (Ex: "Mar - Jul")
  String _formatDateRange(DateTime start, DateTime end) {
    List<String> months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return "${months[start.month - 1]} - ${months[end.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    // O Consumer escuta qualquer mudança no banco de dados e redesenha a tela
    return Consumer<AcademicProvider>(
      builder: (context, provider, child) {
        final periods = provider.periods;

        // Tenta encontrar o período marcado como atual
        PeriodModel? currentPeriod;
        try {
          currentPeriod = periods.firstWhere((p) => p.isCurrent);
        } catch (e) {
          currentPeriod = null;
        }

        // Pega o resto para o histórico (ordenado do mais novo para o mais velho)
        final historyPeriods = periods.where((p) => !p.isCurrent).toList();
        // Opcional: ordenar por data (se quiser)
        // historyPeriods.sort((a, b) => b.startDate.compareTo(a.startDate));

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Meus Períodos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                Text("Gerencie seu histórico acadêmico", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPeriodScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Adicionar"),
                ),
              )
            ],
          ),
          body: periods.isEmpty 
              ? _buildEmptyState() // Mostra algo se não tiver nada cadastrado
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // SEÇÃO PERÍODO ATUAL
                    if (currentPeriod != null) ...[
                      Row(
                        children: const [
                          Icon(Icons.circle, color: AppColors.primary, size: 10),
                          SizedBox(width: 8),
                          Text("PERÍODO ATUAL", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCurrentPeriodCard(context, currentPeriod),
                      const SizedBox(height: 32),
                    ],

                    // SEÇÃO HISTÓRICO
                    if (historyPeriods.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Histórico", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Filtrar", style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Lista dinâmica do histórico
                      ...historyPeriods.map((period) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildHistoryCard(context, period), // <--- PASSE O CONTEXT AQUI
                      )),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.school_outlined, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text("Nenhum período encontrado", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildCurrentPeriodCard(BuildContext context, PeriodModel period) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                period.name, // Nome real do banco
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Em andamento", style: TextStyle(color: AppColors.primary, fontSize: 10)),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateRange(period.startDate, period.endDate), // Datas reais
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          
          // Barra de Progresso (Fixa por enquanto, depois calcularemos com as datas)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.5, 
              backgroundColor: Colors.grey[800],
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PeriodDetailsScreen(period: period)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Ver Detalhes", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, PeriodModel period) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PeriodDetailsScreen(period: period)),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _formatDateRange(period.startDate, period.endDate),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Média", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  Text(
                    "--", // Placeholder até termos notas
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
    }
}
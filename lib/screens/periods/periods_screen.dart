import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'add_period_screen.dart';
import 'period_details_screen.dart';

class PeriodsScreen extends StatelessWidget {
  const PeriodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Meus Períodos",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              "Gerencie seu histórico acadêmico",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {
                // --- NAVEGAÇÃO TEMPORÁRIA PARA TESTE ---
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPeriodScreen()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Adicionar"),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // SEÇÃO PERÍODO ATUAL
          Row(
            children: const [
              Icon(Icons.circle, color: AppColors.primary, size: 10),
              SizedBox(width: 8),
              Text(
                "PERÍODO ATUAL",
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Card do Período Atual (Destaque)
          _buildCurrentPeriodCard(context),

          const SizedBox(height: 32),

          // SEÇÃO HISTÓRICO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Histórico",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text("Filtrar", style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de Períodos Passados (Mockados)
          _buildHistoryCard("2023.2", "Ago - Dez", "8.5"),
          const SizedBox(height: 12),
          _buildHistoryCard("2023.1", "Fev - Jul", "7.9"),
          const SizedBox(height: 12),
          _buildHistoryCard("2022.2", "Ago - Dez", "9.2"),
        ],
      ),
    );
  }

  Widget _buildCurrentPeriodCard(BuildContext context) { // Adicionei o context aqui para o Navigator funcionar
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
              const Text(
                "2024.1",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Em andamento",
                  style: TextStyle(color: AppColors.primary, fontSize: 10),
                ),
              )
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Março - Julho",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          
          // Barra de Progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.4, // 40%
              backgroundColor: Colors.grey[800],
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),

          // Botão Ver Detalhes (O que você estava tentando colar)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PeriodDetailsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Ver Detalhes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryCard(String title, String subtitle, String media) {
    return Container(
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
                  title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
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
                media,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
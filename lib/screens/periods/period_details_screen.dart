import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../subject/add_subject_screen.dart';
import '../subject/subject_details_screen.dart';

class PeriodDetailsScreen extends StatelessWidget {
  const PeriodDetailsScreen({super.key});

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
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // CONTEÚDO COM SCROLL
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // Espaço extra para o botão
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TÍTULO E SUBTÍTULO
                const Text(
                  "5º Semestre",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Engenharia de Software • 2023.2",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),

                const SizedBox(height: 24),

                // 2. NOVO CARD DE STATUS (Unificado)
                _buildStatusCard(),

                const SizedBox(height: 32),

                // 3. CABEÇALHO DA LISTA
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
                      child: const Text(
                        "6 Matérias",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 4. LISTA DE MATÉRIAS (Com indicador de faltas)
                // OBS: Agora passamos 'context' como primeiro argumento
                _buildSubjectItem(
                  context, 
                  title: "Estrutura de Dados",
                  professor: "Prof. Silva",
                  faults: 0, // Verde
                  color: Colors.green,
                  icon: Icons.code,
                ),
                const SizedBox(height: 12),
                _buildSubjectItem(
                  context,
                  title: "Cálculo II",
                  professor: "Prof. Santos",
                  faults: 2, // Amarelo
                  color: Colors.green,
                  icon: Icons.functions,
                ),
                const SizedBox(height: 12),
                _buildSubjectItem(
                  context,
                  title: "Banco de Dados",
                  professor: "Prof. Oliveira",
                  faults: 3, // Vermelho
                  color: Colors.teal,
                  icon: Icons.storage,
                ),
                const SizedBox(height: 12),
                _buildSubjectItem(
                  context,
                  title: "Programação Web",
                  professor: "Prof. Costa",
                  faults: 1, // Amarelo
                  color: Colors.blue,
                  icon: Icons.web,
                ),
                const SizedBox(height: 12),
                _buildSubjectItem(
                  context,
                  title: "Empreendedorismo",
                  professor: "Prof. Mendes",
                  faults: 4, // Vermelho
                  color: Colors.green.shade800,
                  icon: Icons.lightbulb,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 5. BOTÃO FLUTUANTE EMBAIXO
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
                    MaterialPageRoute(builder: (context) => const AddSubjectScreen()),
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

  // --- WIDGET DO CARD DE STATUS GRANDE ---
  Widget _buildStatusCard() {
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
              Icon(Icons.notes, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Status do Período",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Lado Esquerdo: Média
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "8.5",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Média Atual",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              // Lado Direito: Faltas Críticas
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "2",
                    style: TextStyle(
                      color: Color(0xFFFF5252), // Vermelho alerta
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text(
                        "Faltas Críticas",
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

  // --- WIDGET DA LINHA DA MATÉRIA (ATUALIZADO COM NAVEGAÇÃO) ---
  Widget _buildSubjectItem(
    BuildContext context, { // Adicionado Context aqui
    required String title,
    required String professor,
    required int faults,
    required Color color,
    required IconData icon,
  }) {
    // Lógica simples para cor do status
    Color statusColor;
    if (faults == 0) {
      statusColor = AppColors.primary; // Verde (Sem faltas)
    } else if (faults <= 2) {
      statusColor = Colors.amber; // Amarelo (Atenção)
    } else {
      statusColor = const Color(0xFFFF5252); // Vermelho (Crítico)
    }

    // Envolvido em GestureDetector para permitir o clique
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubjectDetailsScreen()),
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
            // Ícone Quadrado
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Títulos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    professor,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            // Badge de Faltas
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
                    "$faults ${faults == 1 ? 'falta' : 'faltas'}",
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
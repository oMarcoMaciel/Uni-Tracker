import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SubjectDetailsScreen extends StatefulWidget {
  const SubjectDetailsScreen({super.key});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  // Estado local para controle de faltas
  int _faltas = 4;
  final int _limiteFaltas = 15;

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CABEÇALHO (Nome, Prof, Horário)
            const Text(
              "Matemática Discreta",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 4),
                const Text("Prof. Almeida", style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 4),
                const Text("Seg/Qua 10:00", style: TextStyle(color: AppColors.textSecondary)),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Média: 7.8", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildAssessmentItem(label: "P1", title: "Prova 1", date: "12/03/2024", grade: "8.5", color: Colors.blue),
            const SizedBox(height: 12),
            _buildAssessmentItem(label: "P2", title: "Prova 2", date: "15/05/2024", grade: "7.0", color: Colors.purple),
            const SizedBox(height: 12),
            _buildAssessmentItem(label: "TF", title: "Trabalho Final", date: "Pendente", grade: "-", color: Colors.orange),
            
            const SizedBox(height: 16),
            
            // Botão Adicionar Avaliação (Tracejado)
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, style: BorderStyle.solid), // Simulação de tracejado pode ser feita com pacote, mas solid funciona visualmente bem dark
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.02),
              ),
              child: TextButton.icon(
                onPressed: () {},
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
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
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
                  const Text(
                    "Digite suas anotações aqui... Ex: Estudar capítulo 4 para a próxima aula.",
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Última edição: hoje 14:20", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      Icon(Icons.save, color: AppColors.primary, size: 18),
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

  Widget _buildAttendanceCard() {
    double progress = _faltas / _limiteFaltas;
    
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
                    child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text("Controle de Faltas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("EM DIA", style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
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
                    TextSpan(text: "$_faltas", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    TextSpan(text: " / $_limiteFaltas permitidas", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildControlButton(Icons.remove, () {
                if (_faltas > 0) setState(() => _faltas--);
              }),
              const SizedBox(width: 12),
              _buildControlButton(Icons.add, () {
                setState(() => _faltas++);
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: icon == Icons.add ? AppColors.primary : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: icon == Icons.add ? Colors.black : Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildAssessmentItem({required String label, required String title, required String date, required String grade, required Color color}) {
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
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(grade, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
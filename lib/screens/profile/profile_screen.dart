import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/subject_model.dart';
import '../../models/period_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Função auxiliar para calcular o CR (Média Global)
  String _calculateGlobalAverage() {
    final box = Hive.box<SubjectModel>('subjects');
    final subjects = box.values.toList();
    
    if (subjects.isEmpty) return "0.0";

    double totalSum = 0;
    int count = 0;

    for (var subject in subjects) {
      if (subject.grades.isNotEmpty) {
        double subjectAvg = subject.grades.map((g) => g.value).reduce((a, b) => a + b) / subject.grades.length;
        totalSum += subjectAvg;
        count++;
      }
    }

    if (count == 0) return "0.0";
    return (totalSum / count).toStringAsFixed(1);
  }

  // Função auxiliar para contar períodos (Semestre atual aproximado)
  String _calculateSemesterCount() {
    final box = Hive.box<PeriodModel>('periodsBox');
    int count = box.length;
    return count == 0 ? "1º" : "${count}º";
  }

  // Função para pegar as iniciais do nome
  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    List<String> names = name.trim().split(" ");
    String initials = names[0][0];
    if (names.length > 1) {
      initials += names[names.length - 1][0];
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Futuro: Editar Perfil
            },
            child: const Text(
              "Editar",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      // OUVINTE DO USUÁRIO
      body: ValueListenableBuilder(
        valueListenable: Hive.box<UserModel>('userBox').listenable(),
        builder: (context, Box<UserModel> box, _) {
          
          final user = box.get('currentUser');

          // Caso de segurança (não deve acontecer se o onboarding funcionar)
          if (user == null) {
            return const Center(child: Text("Usuário não encontrado", style: TextStyle(color: Colors.white)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // 1. AVATAR DINÂMICO
                Center(
                  child: Stack(
                    children: [
                      // Glow
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Avatar com Iniciais
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface, // Cor de fundo do avatar
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(user.name),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Ícone de lápis
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 2. NOME E CURSO REAIS
                Text(
                  user.name,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "${user.course} - ${user.university}",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // 3. ESTATÍSTICAS REAIS
                // Como as notas e períodos mudam, usamos ValueListenable para atualizar isso também
                ValueListenableBuilder(
                  valueListenable: Hive.box<SubjectModel>('subjects').listenable(),
                  builder: (context, _, __) {
                    return Column(
                      children: [
                        _buildStatRow("Média Global (CR)", _calculateGlobalAverage()),
                        const Divider(color: Colors.white10, height: 32),
                        _buildStatRow("Períodos Cadastrados", _calculateSemesterCount()),
                        const Divider(color: Colors.white10, height: 32),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 20),

                // 4. INFORMAÇÕES PESSOAIS
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Informações Pessoais",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildInfoItem("Email Cadastrado", user.email, Icons.email_outlined),
                // Removi a matrícula pois não pedimos no cadastro, mas você pode adicionar depois
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Icon(icon, color: AppColors.textSecondary, size: 20),
      ],
    );
  }
}
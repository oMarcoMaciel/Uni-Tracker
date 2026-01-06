import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              // Ação de editar perfil futura
            },
            child: const Text(
              "Editar",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. AVATAR COM GLOW
            Center(
              child: Stack(
                children: [
                  // Efeito de brilho atrás
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2), // Brilho verde
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Imagem do Avatar
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=68'), // Imagem ilustrativa
                  ),
                  // Ícone de lápis flutuante
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.black, size: 20),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 2. NOME E CURSO
            const Text(
              "João Silva",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Engenharia de Software - USP",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),

            const SizedBox(height: 40),

            // 3. ESTATÍSTICAS (CR e Semestre)
            _buildStatRow("CR (GPA)", "8.5"),
            const Divider(color: Colors.white10, height: 32),
            _buildStatRow("Semestre", "5º"),
            const Divider(color: Colors.white10, height: 32),

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
            
            _buildInfoItem("Matrícula", "20214589", Icons.badge_outlined),
            const SizedBox(height: 24),
            _buildInfoItem("Email Institucional", "joao.silva@usp.br", Icons.email_outlined),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para linha de estatística (Texto esq + Valor verde dir)
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

  // Widget auxiliar para info pessoal (Label cinza, Valor branco, Ícone dir)
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        Icon(icon, color: AppColors.textSecondary, size: 20),
      ],
    );
  }
}
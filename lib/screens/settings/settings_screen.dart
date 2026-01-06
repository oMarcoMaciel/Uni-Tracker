import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Configurações",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // GRUPO 1: Preferências Gerais
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.home_filled,
                    title: "Tela Inicial Padrão",
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("2026.1", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),
                  _buildSettingItem(
                    icon: Icons.dark_mode,
                    title: "Tema Escuro",
                    trailing: Switch(
                      value: _isDarkMode,
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withOpacity(0.3),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[800],
                      onChanged: (val) => setState(() => _isDarkMode = val),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // GRUPO 2: Informações
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.person,
                    title: "Editar Perfil",
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),
                  _buildSettingItem(
                    icon: Icons.info,
                    title: "Sobre o App",
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("v1.0.0", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),
                  _buildSettingItem(
                    icon: Icons.help,
                    title: "Ajuda",
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // BOTÃO SAIR
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: const Color(0xFFFF5252), // Vermelho
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Sair da Conta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "Marco Maciel © 2026",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Altura ajustada
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: title == "Ajuda" ? Colors.pink.withOpacity(0.2) : // Exemplo de cor diferente p/ ajuda
                     title == "Editar Perfil" ? Colors.purple.withOpacity(0.2) :
                     Colors.blueGrey.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, 
              color: title == "Ajuda" ? Colors.pinkAccent : 
                     title == "Editar Perfil" ? Colors.purpleAccent :
                     Colors.blue[200], 
              size: 20
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ),
          trailing,
        ],
      ),
    );
  }
}
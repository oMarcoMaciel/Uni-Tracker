import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // <--- Import do Hive
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  String _startupOption = 'home'; // Padrão inicial

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // --- 1. CARREGAR CONFIGURAÇÃO ---
  void _loadSettings() {
    var box = Hive.box('settings');
    setState(() {
      _startupOption = box.get('startup_screen', defaultValue: 'home');
    });
  }

  // --- 2. SALVAR CONFIGURAÇÃO ---
  void _updateStartupOption(String value) {
    var box = Hive.box('settings');
    box.put('startup_screen', value);
    setState(() {
      _startupOption = value;
    });
    Navigator.pop(context); // Fecha o modal
  }

  // --- 3. MODAL DE SELEÇÃO ---
  void _showStartupOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Escolha a tela inicial",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildOptionTile("Menu Inicial (Dashboard)", "home"),
              const Divider(color: Colors.white10),
              _buildOptionTile("Lista de Períodos", "periods"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(String title, String value) {
    final isSelected = _startupOption == value;
    return ListTile(
      onTap: () => _updateStartupOption(value),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: isSelected 
        ? const Icon(Icons.check_circle, color: AppColors.primary)
        : const Icon(Icons.circle_outlined, color: Colors.grey),
    );
  }

  // Helper para mostrar o texto bonito no botão
  String _getStartupLabel() {
    switch (_startupOption) {
      case 'periods': return "Lista de Períodos";
      case 'home':
      default: return "Dashboard";
    }
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
                    onTap: _showStartupOptions, // <--- Agora abre o modal
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Texto dinâmico baseado na escolha
                        Text(_getStartupLabel(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1, indent: 56),
                  _buildSettingItem(
                    icon: Icons.dark_mode,
                    title: "Tema Escuro",
                    trailing: Switch(
                      value: _isDarkMode,
                      activeThumbColor: AppColors.primary,
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

  // Atualizei este widget para aceitar o onTap
  Widget _buildSettingItem({
    required IconData icon, 
    required String title, 
    required Widget trailing,
    VoidCallback? onTap, // <--- Novo parâmetro opcional
  }) {
    return InkWell( // <--- Adicionei InkWell para o clique funcionar
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: title == "Ajuda" ? Colors.pink.withOpacity(0.2) :
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
      ),
    );
  }
}
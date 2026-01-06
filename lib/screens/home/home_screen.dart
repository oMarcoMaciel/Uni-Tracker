import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // <--- Import do Hive
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart'; // <--- Import do User Model
import '../periods/periods_screen.dart'; 
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função auxiliar para pegar as iniciais (Igual à tela de Perfil)
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
    // Lista de telas que o rodapé controla
    final List<Widget> screens = [
      _buildDashboard(),     // Índice 0
      const PeriodsScreen(), // Índice 1
      const ProfileScreen(), // Índice 2
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      
      body: screens[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Cursos'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(), // <--- Agora chama o Header dinâmico
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 32),
            const Text("Acesso Rápido", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildQuickAccessItem(
              icon: Icons.calendar_month, 
              title: "Períodos", 
              subtitle: "Histórico de notas", 
              onTap: () => _onItemTapped(1) 
            ),
            const SizedBox(height: 12),
            _buildQuickAccessItem(
              icon: Icons.settings, 
              title: "Ajustes", 
              subtitle: "Preferências", 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

   // --- HEADER ATUALIZADO ---
   Widget _buildHeader() {
    // Usa ValueListenableBuilder para atualizar se o usuário editar o perfil
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserModel>('userBox').listenable(),
      builder: (context, Box<UserModel> box, _) {
        final user = box.get('currentUser');
        final userName = user?.name ?? "Visitante"; // Valor padrão se der erro

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // AVATAR COM INICIAIS
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(userName),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bem-vindo de volta,", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(
                      userName, // Nome Dinâmico
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ],
            ),
            Stack(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: Colors.white)),
                Positioned(
                  right: 12, top: 12,
                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                )
              ],
            )
          ],
        );
      }
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("MÉDIA GERAL", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Icon(Icons.school, color: AppColors.surface, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("8.5", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.trending_up, color: AppColors.primary, size: 16),
                    SizedBox(width: 4),
                    Text("+0.2 este mês", style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("SEMESTRE", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Icon(Icons.pie_chart, color: AppColors.surface, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("75%", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 6, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft, widthFactor: 0.75,
                    child: Container(decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10))),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.blue[200]),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
      ),
    );
  }
}
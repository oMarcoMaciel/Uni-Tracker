import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../periods/periods_screen.dart'; 
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista de telas que o rodapé controla
    final List<Widget> screens = [
      _buildDashboard(),     // Índice 0: Início
      const PeriodsScreen(), // Índice 1: Cursos 
      const ProfileScreen(), // Índice 2: Perfil 
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      
      // Exibe a tela correspondente ao índice selecionado
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

  // --- O CÓDIGO DO DASHBOARD FICOU AQUI EMBAIXO ---
  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 32),
            const Text("Acesso Rápido", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildQuickAccessItem(
              icon: Icons.calendar_month, 
              title: "Períodos", 
              subtitle: "Histórico de notas", 
              onTap: () => _onItemTapped(1) // Atalho para ir para a aba Cursos
            ),
            const SizedBox(height: 12),
            _buildQuickAccessItem(
              icon: Icons.settings, 
              title: "Ajustes", 
              subtitle: "Preferências", 
              onTap: () {
                // TEM QUE TER ESSE CÓDIGO AQUI:
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

  // Widgets auxiliares (Header, Cards, etc) continuam aqui...
  // (Para economizar espaço na resposta, mantenha os métodos _buildHeader, 
  // _buildSummaryCards e _buildQuickAccessItem que já estavam no arquivo anterior.
  // Se você apagou, me avise que mando eles de novo!)
  
  // --- COLE AQUI OS WIDGETS AUXILIARES ANTIGOS (_buildHeader, etc) ---
  
   Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
              backgroundColor: AppColors.surface,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Bem-vindo de volta,", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text("Gabriel Silva", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
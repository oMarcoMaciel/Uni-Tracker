import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../main.dart'; 

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _courseController = TextEditingController();
  final _uniController = TextEditingController();

  Future<void> _finishOnboarding() async {
    // Validação simples (Nome, Curso e Email obrigatórios)
    if (_nameController.text.isEmpty ||
        _courseController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha nome, e-mail e curso.')),
      );
      return;
    }

    var userBox = await Hive.openBox<UserModel>('userBox');
    final user = UserModel(
      name: _nameController.text,
      email: _emailController.text,
      course: _courseController.text,
      university: _uniController.text,
    );
    await userBox.put('currentUser', user);

    var settingsBox = await Hive.openBox('settings');
    await settingsBox.put('is_first_run', false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const UniTrackerApp(startupScreen: 'home', isFirstRun: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ALTERAÇÃO AQUI: GestureDetector para fechar o teclado
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.waving_hand, color: Colors.amber, size: 40),
                const SizedBox(height: 20),
                const Text(
                  "Bem-vindo ao\nUniTracker!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Vamos configurar seu perfil acadêmico para começar.",
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 40),

                _buildTextField(
                    label: "Como você se chama?",
                    controller: _nameController,
                    icon: Icons.person),
                const SizedBox(height: 20),

                _buildTextField(
                    label: "Qual seu e-mail?",
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),

                _buildTextField(
                    label: "Qual seu curso?",
                    controller: _courseController,
                    icon: Icons.school),
                const SizedBox(height: 20),
                _buildTextField(
                    label: "Nome da Instituição (Opcional)",
                    controller: _uniController,
                    icon: Icons.account_balance),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _finishOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Começar",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
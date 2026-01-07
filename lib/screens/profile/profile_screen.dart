import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/subject_model.dart';
import '../../models/period_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- 1. LÓGICA DE UPLOAD DA FOTO (MANTIDA) ---
  Future<void> _pickAndSaveImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String path = directory.path;
        final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File localImage = await File(image.path).copy('$path/$fileName');

        var box = Hive.box<UserModel>('userBox');
        var user = box.get('currentUser');

        if (user != null) {
          // Apaga foto antiga se existir
          if (user.profileImagePath != null) {
            final oldFile = File(user.profileImagePath!);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          }

          user.profileImagePath = localImage.path;
          user.save();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao selecionar foto.')),
        );
      }
    }
  }

  // --- 2. NOVA LÓGICA: REMOVER FOTO ---
  Future<void> _removeProfileImage(BuildContext context) async {
    var box = Hive.box<UserModel>('userBox');
    var user = box.get('currentUser');

    if (user != null && user.profileImagePath != null) {
      try {
        final file = File(user.profileImagePath!);
        if (await file.exists()) {
          await file.delete(); // Deleta o arquivo físico
        }
        user.profileImagePath = null; // Remove a referência no Hive
        user.save(); // Atualiza a tela
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto removida com sucesso.')),
          );
        }
      } catch (e) {
        // Tratar erro silenciosamente ou avisar usuário
      }
    }
  }

  // --- 3. NOVA LÓGICA: EXIBIR MENU DE OPÇÕES ---
  void _showImageOptions(BuildContext context, bool hasImage) {
    // Se não tem imagem, vai direto para a galeria
    if (!hasImage) {
      _pickAndSaveImage(context);
      return;
    }

    // Se tem imagem, mostra o menu inferior
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface, // Fundo escuro conforme seu tema
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Alterar Foto de Perfil', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  _pickAndSaveImage(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Remover Foto de Perfil', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  _removeProfileImage(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- CÁLCULOS (MANTIDOS) ---
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

  String _calculateSemesterCount() {
    final box = Hive.box<PeriodModel>('periodsBox');
    int count = box.length;
    return count == 0 ? "1º" : "${count}º";
  }

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
        title: const Text("Perfil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () { /* Futuro: Editar dados de texto */ },
            child: const Text("Editar", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<UserModel>('userBox').listenable(),
        builder: (context, Box<UserModel> box, _) {
          final user = box.get('currentUser');
          if (user == null) return const Center(child: Text("Erro: Usuário não encontrado"));

          // Verifica se o arquivo existe de fato no celular
          bool hasImage = user.profileImagePath != null && File(user.profileImagePath!).existsSync();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // --- ÁREA DO AVATAR ---
                Center(
                  child: Stack(
                    children: [
                      // 1. Brilho
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
                          ],
                        ),
                      ),
                      
                      // 2. Imagem ou Iniciais
                      GestureDetector(
                        // MUDANÇA AQUI: Chama o menu de opções
                        onTap: () => _showImageOptions(context, hasImage),
                        child: Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.primary, width: 2),
                            image: hasImage 
                              ? DecorationImage(
                                  image: FileImage(File(user.profileImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          ),
                          child: hasImage 
                            ? null 
                            : Center(
                                child: Text(
                                  _getInitials(user.name),
                                  style: const TextStyle(color: AppColors.primary, fontSize: 40, fontWeight: FontWeight.bold),
                                ),
                              ),
                        ),
                      ),

                      // 3. Ícone Câmera
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                           // MUDANÇA AQUI TAMBÉM: Mesmo comportamento do avatar
                          onTap: () => _showImageOptions(context, hasImage),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text("${user.course} - ${user.university}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 16), textAlign: TextAlign.center),

                const SizedBox(height: 40),

                // Estatísticas
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
                const Align(alignment: Alignment.centerLeft, child: Text("Informações Pessoais", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 24),
                _buildInfoItem("Email Cadastrado", user.email, Icons.email_outlined),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      ])),
      Icon(icon, color: AppColors.textSecondary, size: 20),
    ]);
  }
}
import 'dart:io'; // <--- OBRIGATÓRIO: Para usar File()
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'; // Import do Tutorial
import '../../core/theme/app_colors.dart';
import '../../core/constants/text_formatters.dart';
import '../../models/user_model.dart';
import '../../models/period_model.dart';
import '../../models/subject_model.dart';
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
  final ScrollController _scrollController = ScrollController();
  int _currentTargetIndex = 0;

  // Keys para o Tutorial
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _summaryKey = GlobalKey();
  final GlobalKey _periodsKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();

  TutorialCoachMark? tutorial; // Variável do Tutorial
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Agenda a verificação do tutorial logo após o build da tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAndShowTutorial() {
    var settingsBox = Hive.box('settings');
    // Verifica se o tutorial já foi mostrado (padrão false)
    bool tutorialShown = settingsBox.get('tutorial_shown', defaultValue: false);

    if (!tutorialShown) {
      // Delay maior para garantir que o layout (inclusive via Hive) esteja estável
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _initTargets();
          _showTutorial();
        }
      });
    }
  }

  void _showTutorial() {
    _currentTargetIndex = 0;
    tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.background,
      hideSkip: true,
      paddingFocus: 0, // Removendo padding extra global
      opacityShadow: 0.8,
      onFinish: () {
        Hive.box('settings').put('tutorial_shown', true);
      },
      onClickTarget: (target) {
        _handleNextTarget();
      },
      onClickOverlay: (target) {
        _handleNextTarget();
      },
      onSkip: () {
        Hive.box('settings').put('tutorial_shown', true);
        return true;
      },
    );
    
    tutorial?.show(context: context);
  }

  Future<void> _handleNextTarget() async {
    final nextIndex = _currentTargetIndex + 1;
    if (nextIndex < targets.length) {
      final nextKey = _getTargetKey(nextIndex);
      if (nextKey?.currentContext != null) {
        await Scrollable.ensureVisible(
          nextKey!.currentContext!,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    _currentTargetIndex = nextIndex;
    tutorial?.next();
  }

  GlobalKey? _getTargetKey(int index) {
    if (index < 0 || index >= 4) return null;
    return <GlobalKey>[_headerKey, _summaryKey, _periodsKey, _settingsKey][index];
  }

  void _initTargets() {
    targets = [
      _createTarget(
        identify: "header",
        keyTarget: _headerKey,
        title: "Bem-vindo!",
        description: "Aqui você vê seu perfil e notificações importantes.",
        align: ContentAlign.bottom,
      ),
      _createTarget(
        identify: "summary",
        keyTarget: _summaryKey,
        title: "Resumo Acadêmico",
        description: "Acompanhe sua média geral e o progresso do semestre atual em tempo real.",
        align: ContentAlign.bottom,
      ),
      _createTarget(
        identify: "periods",
        keyTarget: _periodsKey,
        title: "Gerencie seus Períodos",
        description: "Toque aqui para adicionar semestres, disciplinas e registrar suas notas.",
        align: ContentAlign.top,
      ),
      _createTarget(
        identify: "settings",
        keyTarget: _settingsKey,
        title: "Ajustes", // Renomeado de Configurações para Ajustes
        description: "Personalize sua experiência e ajustes do aplicativo.",
        align: ContentAlign.top,
      ),
    ];
  }

  TargetFocus _createTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required ContentAlign align,
    double radius = 16, // Raio padrão para combinar com os cards
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      alignSkip: Alignment.topRight,
      radius: radius,
      shape: ShapeLightFocus.RRect,
      paddingFocus: 5, // Padding ajustado localmente
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
             return GestureDetector(
              onTap: () => tutorial?.next(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                     BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    final List<Widget> screens = [
      _buildDashboard(),
      const PeriodsScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      // Em apps tradicionais, o botão voltar só fecha o app na rota/aba inicial.
      // Como as abas são trocadas dentro da mesma rota, precisamos interceptar.
      canPop: _selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
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
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Cursos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 100, // Extra padding para garantir scroll até o final no tutorial
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(key: _headerKey, child: _buildHeader()),
            const SizedBox(height: 24),
            Container(key: _summaryKey, child: _buildSummaryCards()),
            const SizedBox(height: 32),
            const Text(
              "Acesso Rápido",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickAccessItem(
              key: _periodsKey,
              icon: Icons.calendar_month,
              title: "Períodos",
              subtitle: "Histórico de notas",
              onTap: () => _onItemTapped(1),
            ),
            const SizedBox(height: 12),
            _buildQuickAccessItem(
              key: _settingsKey,
              icon: Icons.settings,
              title: "Ajustes",
              subtitle: "Preferências",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserModel>('userBox').listenable(),
      builder: (context, Box<UserModel> box, _) {
        final user = box.get('currentUser');
        final userName = user?.name ?? "Estudante";
        final displayUserName = formatFirstAndLastName(userName);

        // --- CORREÇÃO AQUI: Usando profileImagePath e verificando existência ---
        final imagePath = user?.profileImagePath;
        final bool hasImage =
            imagePath != null &&
            imagePath.isNotEmpty &&
            File(imagePath).existsSync(); // Verifica se o arquivo existe mesmo

        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      // Se tiver imagem válida, mostra ela. Se não, nulo.
                      image: hasImage
                          ? DecorationImage(
                              image: FileImage(File(imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    // Se NÃO tiver imagem, mostra as iniciais
                    child: hasImage
                        ? null
                        : Center(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bem-vindo de volta,",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          displayUserName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<PeriodModel>('periodsBox').listenable(),
      builder: (context, Box<PeriodModel> periodsBox, _) {
        double progress = 0.0;

        try {
          final currentPeriod = periodsBox.values.firstWhere(
            (p) => p.isCurrent,
          );

          final totalDays = currentPeriod.endDate
              .difference(currentPeriod.startDate)
              .inDays;
          final elapsedDays = DateTime.now()
              .difference(currentPeriod.startDate)
              .inDays;

          if (totalDays > 0) {
            progress = elapsedDays / totalDays;
            if (progress < 0) progress = 0;
            if (progress > 1) progress = 1;
          }
        } catch (e) {
          // Nenhum período ativo encontrado
        }

        return ValueListenableBuilder(
          valueListenable: Hive.box<SubjectModel>('subjects').listenable(),
          builder: (context, Box<SubjectModel> subjectsBox, _) {
            double totalAvg = 0;
            int count = 0;

            for (var subject in subjectsBox.values) {
              if (subject.grades.isNotEmpty) {
                double subjectAvg =
                    subject.grades.map((g) => g.value).reduce((a, b) => a + b) /
                    subject.grades.length;
                totalAvg += subjectAvg;
                count++;
              }
            }

            String globalAvg = count > 0
                ? (totalAvg / count).toStringAsFixed(1)
                : "0.0";

            return Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "MÉDIA GERAL",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            Icon(
                              Icons.school,
                              color: AppColors.surface,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          globalAvg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Acumulado",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "SEMESTRE",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            Icon(
                              Icons.pie_chart,
                              color: AppColors.surface,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildQuickAccessItem({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue[200]),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
      ),
    );
  }
}

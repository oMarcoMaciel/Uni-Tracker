import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'; // Import Tutorial
import '../../core/constants/text_formatters.dart';
import '../../core/theme/app_colors.dart';
import '../../models/period_model.dart';
import 'add_period_screen.dart';
import 'period_details_screen.dart';

class PeriodsScreen extends StatefulWidget {
  const PeriodsScreen({super.key});

  @override
  State<PeriodsScreen> createState() => _PeriodsScreenState();
}

class _PeriodsScreenState extends State<PeriodsScreen> {
  // KEYS DO TUTORIAL
  final GlobalKey _addPeriodKey = GlobalKey();
  final GlobalKey _currentPeriodKey = GlobalKey();
  
  TutorialCoachMark? tutorial; // Variável do Tutorial

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  void _checkAndShowTutorial() {
    var settingsBox = Hive.box('settings');
    bool tutorialPeriodsShown = settingsBox.get('tutorial_periods_shown', defaultValue: false);
    // Só mostra se o tutorial da Home JÁ FOI MOSTRADO (para manter a ordem)
    bool homeTutorialShown = settingsBox.get('tutorial_shown', defaultValue: false);

    if (homeTutorialShown && !tutorialPeriodsShown) {
      // Pequeno delay para garantir que a UI carregou (caso tenha lista)
      Future.delayed(const Duration(milliseconds: 500), () {
        if(mounted) _createAndShowTutorial();
      });
    }
  }

  void _createAndShowTutorial() {
    List<TargetFocus> targets = [];

    // Se tiver períodos, mostra o card do atual, senão foca só no botão de adicionar
    // Precisamos saber se existe o widget na árvore. Como é HiveBuilder, é assíncrono visualmente.
    // Simplesmente adicionamos os targets que existirem.

    // 1. Botão Adicionar (Sempre existe)
    targets.add(
      _createTarget(
        identify: "add_period_btn",
        keyTarget: _addPeriodKey,
        title: "Novo Semestre",
        description: "Comece adicionando um período letivo para organizar suas matérias.",
        align: ContentAlign.bottom,
      ),
    );

    // 2. Se houver card de período atual (vamos tentar adicionar se a chave estiver montada)
    if (_currentPeriodKey.currentContext != null) {
      targets.add(
        _createTarget(
          identify: "current_period_card",
          keyTarget: _currentPeriodKey,
          title: "Seu Período Atual",
          description: "Toque aqui para ver detalhes, adicionar matérias e gerenciar faltas.",
          align: ContentAlign.bottom,
        ),
      );
    }

    tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.background,
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        Hive.box('settings').put('tutorial_periods_shown', true);
      },
      onClickTarget: (target) {
        tutorial?.next();
      },
      onClickOverlay: (target) {
        tutorial?.next();
      },
      onSkip: () {
        Hive.box('settings').put('tutorial_periods_shown', true);
        return true;
      },
    );
    
    tutorial?.show(context: context);
  }

   TargetFocus _createTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required ContentAlign align,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      alignSkip: Alignment.topRight,
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

  // Função auxiliar para formatar datas na lista (Ex: "Mar - Jul")
  String _formatDateRange(DateTime start, DateTime end) {
    List<String> months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return "${months[start.month - 1]} - ${months[end.month - 1]}";
  }

  // --- NOVA FUNÇÃO: CALCULAR PROGRESSO ---
  double _calculateProgress(DateTime start, DateTime end) {
    final now = DateTime.now();

    // Se ainda não começou, progresso é 0
    if (now.isBefore(start)) return 0.0;

    // Se já acabou, progresso é 1 (100%)
    if (now.isAfter(end)) return 1.0;

    // Cálculo da porcentagem decorrida
    final totalDuration = end.difference(start).inDays;
    final elapsedDuration = now.difference(start).inDays;

    // Evita divisão por zero
    if (totalDuration <= 0) return 1.0;

    return elapsedDuration / totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80, // Aumenta a altura da AppBar para dar mais respiro
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10), // Pequeno espaçamento extra no topo
            Text(
              "Meus Períodos",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              "Gerencie seu histórico acadêmico",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              key: _addPeriodKey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPeriodScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Adicionar"),
            ),
          ),
        ],
      ),
      // O ValueListenableBuilder escuta mudanças na caixa 'periodsBox'
      body: ValueListenableBuilder(
        valueListenable: Hive.box<PeriodModel>('periodsBox').listenable(),
        builder: (context, Box<PeriodModel> box, _) {
          // 1. Converte os dados do banco para uma lista
          final periods = box.values.toList();

          // 2. Ordena por data (opcional, mas recomendado)
          periods.sort((a, b) => b.startDate.compareTo(a.startDate));

          // 3. Separa o período atual dos históricos
          PeriodModel? currentPeriod;
          try {
            currentPeriod = periods.firstWhere((p) => p.isCurrent);
          } catch (e) {
            currentPeriod = null;
          }

          final historyPeriods = periods.where((p) => !p.isCurrent).toList();

          // 4. Se a lista estiver vazia, mostra estado vazio
          if (periods.isEmpty) {
            return _buildEmptyState();
          }

          // 5. Constrói a lista
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // SEÇÃO PERÍODO ATUAL
              if (currentPeriod != null) ...[
                Row(
                  children: const [
                    Icon(Icons.circle, color: AppColors.primary, size: 10),
                    SizedBox(width: 8),
                    Text(
                      "PERÍODO ATUAL",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCurrentPeriodCard(context, currentPeriod, key: _currentPeriodKey),
                const SizedBox(height: 32),
              ],

              // SEÇÃO HISTÓRICO
              if (historyPeriods.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Histórico",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Filtrar",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista dinâmica do histórico
                ...historyPeriods.map(
                  (period) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildHistoryCard(context, period),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.school_outlined, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            "Nenhum período encontrado",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPeriodCard(BuildContext context, PeriodModel period, {Key? key}) {
    // CALCULA O PROGRESSO ANTES DE MONTAR O CARD
    double progress = _calculateProgress(period.startDate, period.endDate);

    return GestureDetector(
      key: key,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodDetailsScreen(period: period),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  limitCharacters(period.name, 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Em andamento",
                  style: TextStyle(color: AppColors.primary, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateRange(period.startDate, period.endDate),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Barra de Progresso (AGORA DINÂMICA)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress, // <--- Valor calculado dinamicamente
              backgroundColor: Colors.grey[800],
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PeriodDetailsScreen(period: period),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Ver Detalhes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, PeriodModel period) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodDetailsScreen(period: period),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    limitCharacters(period.name, 28),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _formatDateRange(period.startDate, period.endDate),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Média",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  "--", // Placeholder até conectarmos as notas
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

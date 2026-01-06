import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_colors.dart';
// Imports das telas
import 'screens/home/home_screen.dart';
import 'screens/periods/periods_screen.dart';
// Imports dos modelos
import 'models/period_model.dart';
import 'models/subject_model.dart';
import 'models/grade_model.dart';
// Provider (Se não estiver usando mais, pode remover depois)
import 'package:provider/provider.dart';
import 'providers/academic_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 1. Registra os Adaptadores
  Hive.registerAdapter(PeriodModelAdapter());
  Hive.registerAdapter(SubjectModelAdapter());
  Hive.registerAdapter(GradeModelAdapter());

  // 2. Abre as Caixas (Boxes)
  await Hive.openBox<PeriodModel>('periodsBox'); // Para os períodos
  await Hive.openBox<SubjectModel>('subjects');  // Para as matérias

  // 3. Abre a caixa de Configurações e lê a preferência
  var settingsBox = await Hive.openBox('settings');
  String startupScreen = settingsBox.get('startup_screen', defaultValue: 'home');

  // 4. Passa a preferência para o App
  runApp(UniTrackerApp(startupScreen: startupScreen));
}

class UniTrackerApp extends StatelessWidget {
  // A classe precisa de uma variável para guardar o valor recebido
  final String startupScreen;

  const UniTrackerApp({
    super.key,
    required this.startupScreen, // <--- Recebe aqui
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AcademicProvider()),
      ],
      child: MaterialApp(
        title: 'UniTracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
        ),
        // Configura o suporte ao idioma Português (Brasil)
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        
        // Configura os tradutores automáticos do Flutter
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Em vez de chamar const HomeScreen(), chamamos a função que decide
        home: _decideHomeScreen(),
      ),
    );
  }

  // Função que escolhe a tela baseada na String salva
Widget _decideHomeScreen() {
    // Se a configuração for 'periods', iniciamos no índice 1 (Aba Cursos)
    // Se for 'home', iniciamos no índice 0 (Aba Início)
    
    int initialIndex = 0;
    
    if (startupScreen == 'periods') {
      initialIndex = 1;
    }

    return HomeScreen(initialIndex: initialIndex);
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_colors.dart';
// Imports das telas
import 'screens/home/home_screen.dart';
import 'screens/periods/periods_screen.dart';
import 'screens/onboarding/onboarding_screen.dart'; 
// Imports dos modelos
import 'models/period_model.dart';
import 'models/subject_model.dart';
import 'models/grade_model.dart';
import 'models/user_model.dart'; 
// Provider (Se não estiver usando mais, pode remover depois)
import 'package:provider/provider.dart';
import 'providers/academic_provider.dart';

// --- CONFIGURAÇÃO DE DESENVOLVIMENTO ---
// Mude para TRUE se quiser pular o cadastro durante os testes.
// Mude para FALSE para testar como um usuário novo veria.
const bool DEV_SKIP_ONBOARDING = false; 
// ----------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 1. Registra os Adaptadores
  Hive.registerAdapter(PeriodModelAdapter());
  Hive.registerAdapter(SubjectModelAdapter());
  Hive.registerAdapter(GradeModelAdapter());
  Hive.registerAdapter(UserModelAdapter()); 

  // 2. Abre as Caixas (Boxes)
  await Hive.openBox<PeriodModel>('periodsBox'); // Para os períodos
  await Hive.openBox<SubjectModel>('subjects');  // Para as matérias
  await Hive.openBox<UserModel>('userBox'); // <--- Para novo usuário

  // 3. Abre a caixa de Configurações e lê a preferência
  var settingsBox = await Hive.openBox('settings');
  String startupScreen = settingsBox.get('startup_screen', defaultValue: 'home');

  bool isFirstRun = settingsBox.get('is_first_run', defaultValue: true);

  // 4. Passa a preferência para o App
  runApp(UniTrackerApp(startupScreen: startupScreen, isFirstRun: isFirstRun));
}

class UniTrackerApp extends StatelessWidget {
  final String startupScreen;
  final bool isFirstRun;

  const UniTrackerApp({
    super.key,
    required this.startupScreen,
    required this.isFirstRun,
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
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        
        // --- CORREÇÃO AQUI ---
        // Chama a função que verifica o Onboarding primeiro
        home: _decideInitialScreen(), 
      ),
    );
  }

  // Função Mestra: Decide se vai para Onboarding ou Home
  Widget _decideInitialScreen() {
    // 1. Se for modo DEV e quisermos pular
    if (DEV_SKIP_ONBOARDING) {
       return _decideHomeScreen();
    }

    // 2. Se for a primeira vez do usuário real
    if (isFirstRun) {
      return const OnboardingScreen();
    }

    // 3. Se já tiver cadastro, decide qual aba da Home abrir
    return _decideHomeScreen();
  }

  // Função Auxiliar: Decide qual aba da Home abrir
  Widget _decideHomeScreen() {
    int initialIndex = 0;
    
    if (startupScreen == 'periods') {
      initialIndex = 1;
    }

    return HomeScreen(initialIndex: initialIndex);
  }
}

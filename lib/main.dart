import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'core/theme/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'models/period_model.dart'; 
import 'models/subject_model.dart'; 
import 'models/grade_model.dart';
import 'package:provider/provider.dart'; 
import 'providers/academic_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(PeriodModelAdapter());
  Hive.registerAdapter(SubjectModelAdapter());
  Hive.registerAdapter(GradeModelAdapter()); 
  await Hive.openBox<SubjectModel>('subjects'); 

  await Hive.openBox<PeriodModel>('periodsBox');

  runApp(const UniTrackerApp());
}



class UniTrackerApp extends StatelessWidget {
  const UniTrackerApp({super.key});

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
        home: const HomeScreen(),
      ),
    );
  }
}
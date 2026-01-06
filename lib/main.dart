import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const UniTrackerApp());
}

class UniTrackerApp extends StatelessWidget {
  const UniTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        // Configura a fonte padrão para todo o app (ex: Poppins ou Roboto)
        textTheme: GoogleFonts.poppinsTextTheme(), 
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
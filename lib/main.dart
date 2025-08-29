// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Hapus import SharedPreferences, kita tidak memerlukannya di sini lagi
// import 'package:shared_preferences/shared_preferences.dart';

import 'services/database_service.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/account_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/education_viewmodel.dart';
import 'views/splash_view.dart'; // Pastikan import ini benar

Future<void> main() async {
  // Inisialisasi dasar yang diperlukan
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await DatabaseService.instance.database;

  // Langsung jalankan aplikasi, selalu mulai dari SplashView
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CategoryViewModel()),
        ChangeNotifierProvider(create: (ctx) => AccountViewModel()),
        ChangeNotifierProvider(create: (ctx) => TransactionViewModel()),
        ChangeNotifierProvider(create: (ctx) => DashboardViewModel()),
        ChangeNotifierProvider(create: (ctx) => EducationViewModel()),
      ],
      child: MaterialApp(
        title: 'Financial Planner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        // Halaman awal aplikasi SELALU SplashView
        home: const SplashView(),
      ),
    );
  }
}

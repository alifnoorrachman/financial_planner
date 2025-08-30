// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 1. Pastikan import ini ada

import 'services/database_service.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/account_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/education_viewmodel.dart';
import 'views/main_navigation_view.dart';
import 'views/onboarding_view.dart'; // <-- 2. Pastikan import ini ada

Future<void> main() async {
  // Inisialisasi wajib sebelum aplikasi jalan
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await DatabaseService.instance.database;

  // --- LOGIKA ONBOARDING DIMULAI DI SINI ---
  final prefs = await SharedPreferences.getInstance();
  // Mengecek apakah 'hasSeenOnboarding' sudah pernah disimpan.
  // Jika belum, nilainya akan 'false', dan onboarding akan muncul.
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  // --- AKHIR LOGIKA ONBOARDING ---

  // 3. Kirim status onboarding ke widget utama aplikasi
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  // 4. Terima status onboarding dari main()
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CategoryViewModel()),
        ChangeNotifierProvider(create: (ctx) => AccountViewModel()),
        ChangeNotifierProvider(create: (ctx) => TransactionViewModel()),
        ChangeNotifierProxyProvider<CategoryViewModel, DashboardViewModel>(
          create: (context) => DashboardViewModel(
            categoryViewModel:
                Provider.of<CategoryViewModel>(context, listen: false),
          ),
          update: (context, categoryViewModel, dashboardViewModel) =>
              DashboardViewModel(categoryViewModel: categoryViewModel),
        ),
        ChangeNotifierProvider(create: (ctx) => EducationViewModel()),
      ],
      child: MaterialApp(
        title: 'Financial Planner',
        debugShowCheckedModeBanner: false,
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
        // --- 5. Tentukan halaman mana yang jadi halaman utama ---
        home: hasSeenOnboarding
            ? const MainNavigationView() // Jika sudah lihat onboarding, ke sini
            : const OnboardingView(), // Jika belum, ke sini
      ),
    );
  }
}

// lib/views/splash_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // <-- Import package Lottie
import 'package:shared_preferences/shared_preferences.dart';

// Import halaman tujuan
import 'package:financial_planner_app/views/onboarding_view.dart';
import 'package:financial_planner_app/views/main_navigation_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Beri jeda agar animasi Lottie sempat terlihat
    await Future.delayed(
        const Duration(milliseconds: 2500)); // Anda bisa sesuaikan durasi

    final prefs = await SharedPreferences.getInstance();
    final bool onboardingComplete =
        prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    // Logika Routing yang sama seperti sebelumnya
    if (onboardingComplete) {
      // If onboarding is done, go to your MainNavigationView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationView()),
      );
    } else {
      // If it's the first time, go to Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan animasi Lottie Anda di sini
    return Scaffold(
      backgroundColor: Colors.white, // Sesuaikan warna background
      body: Center(
        child: Lottie.asset(
          'assets/animations/wallet_animation.json',
          width: 350, // Sesuaikan ukuran animasi
          height: 350,
        ),
      ),
    );
  }
}

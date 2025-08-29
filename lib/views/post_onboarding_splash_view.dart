// lib/views/post_onboarding_splash_view.dart

import 'dart:async';
import 'package:flutter/material.dart';

// Import halaman tujuan
import 'package:financial_planner_app/views/main_navigation_view.dart';

class PostOnboardingSplashView extends StatefulWidget {
  const PostOnboardingSplashView({super.key});

  @override
  State<PostOnboardingSplashView> createState() =>
      _PostOnboardingSplashViewState();
}

class _PostOnboardingSplashViewState extends State<PostOnboardingSplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      // After the post-onboarding splash, go to MainNavigationView
      // and clear all previous routes.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationView()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text("Pengaturan Selesai!", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

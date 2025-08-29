// views/home_view.dart

import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold adalah kerangka dasar untuk sebuah halaman/layar.
    return Scaffold(
      // AppBar adalah bar judul di bagian atas.
      appBar: AppBar(title: Text('Financial Planner')),
      // body adalah konten utama dari layar.
      body: Center(
        child: Text('Selamat Datang!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

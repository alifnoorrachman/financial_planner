// lib/views/category_setup_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/category_viewmodel.dart';

class CategorySetupView extends StatelessWidget {
  const CategorySetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CategoryViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setup Kategori'),
          centerTitle: true,
        ),
        body: Consumer<CategoryViewModel>(
          builder: (context, viewModel, child) {
            // --- PERBAIKAN DI SINI ---
            // Ganti viewModel.categories menjadi viewModel.allCategories
            return ListView.builder(
              itemCount: viewModel.allCategories.length,
              itemBuilder: (context, index) {
                final category = viewModel.allCategories[index];
                
                return ListTile(
                  leading: Icon(category.icon, size: 30),
                  title: Text(category.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Aksi saat item di-tap (untuk nanti)
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Aksi untuk tombol tambah (akan kita implementasikan nanti)
          },
          tooltip: 'Tambah Kategori',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
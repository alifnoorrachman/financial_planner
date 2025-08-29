// lib/views/education_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/education_viewmodel.dart';

class EducationView extends StatelessWidget {
  const EducationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita tidak perlu Consumer di sini karena datanya tidak akan pernah berubah,
    // cukup panggil ViewModel-nya sekali saja.
    final viewModel = Provider.of<EducationViewModel>(context);
    final items = viewModel.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edukasi & Tips'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // ExpansionTile adalah widget yang bisa di-klik untuk menampilkan/menyembunyikan detail.
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ExpansionTile(
              leading: const Icon(Icons.school_outlined),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(item.content),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
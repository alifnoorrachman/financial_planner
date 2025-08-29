// lib/viewmodels/category_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryViewModel extends ChangeNotifier {
  final List<Category> _allCategories = [
    // --- Kategori Pemasukan ---
    Category(name: 'Gaji', icon: Icons.wallet, type: 'income'),
    Category(name: 'Freelance', icon: Icons.laptop_mac, type: 'income'),
    Category(name: 'Produk Digital', icon: Icons.code, type: 'income'),
    Category(name: 'Pemasukan Lain', icon: Icons.add_card, type: 'income'),

    // --- Kategori Pengeluaran ---
    Category(name: 'Makan & Minum', icon: Icons.restaurant, type: 'expense'),
    Category(name: 'Belanja', icon: Icons.shopping_bag, type: 'expense'),
    Category(name: 'Transportasi', icon: Icons.directions_car, type: 'expense'),
    Category(name: 'Tagihan', icon: Icons.receipt, type: 'expense'),
    Category(name: 'Hiburan', icon: Icons.movie, type: 'expense'),
    Category(name: 'Kesehatan', icon: Icons.healing, type: 'expense'),

    // --- Kategori Lainnya (bisa dianggap pengeluaran) ---
    Category(name: 'Investasi/Tabungan', icon: Icons.savings, type: 'expense'),
    Category(name: 'Tujuan Finansial', icon: Icons.flag, type: 'expense'),
    Category(name: 'Lain-lain', icon: Icons.more_horiz, type: 'expense'),
  ];

  // --- GETTER BARU ---
  // Getter untuk mengambil semua kategori
  List<Category> get allCategories => _allCategories;

  // Getter yang HANYA mengambil kategori PEMASUKAN
  List<Category> get incomeCategories {
    return _allCategories.where((cat) => cat.type == 'income').toList();
  }

  // Getter yang HANYA mengambil kategori PENGELUARAN
  List<Category> get expenseCategories {
    return _allCategories.where((cat) => cat.type == 'expense').toList();
  }
}

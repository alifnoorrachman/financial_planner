// lib/viewmodels/category_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';

class CategoryViewModel extends ChangeNotifier {
  List<Category> _allCategories = [];
  // State baru untuk menyimpan budget bulan yang aktif
  Map<int, double> _monthlyBudgets = {};

  List<Category> get allCategories => _allCategories;
  List<Category> get incomeCategories =>
      _allCategories.where((c) => c.type == 'income').toList();
  List<Category> get expenseCategories =>
      _allCategories.where((c) => c.type == 'expense').toList();

  // Getter untuk mendapatkan budget berdasarkan ID kategori
  double getBudgetForCategory(int categoryId) {
    return _monthlyBudgets[categoryId] ?? 0.0;
  }

  CategoryViewModel() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _allCategories = await DatabaseService.instance.getAllCategories();
    notifyListeners();
  }

  // Fungsi baru untuk memuat budget untuk bulan tertentu
  Future<void> loadBudgetsForMonth(DateTime month) async {
    _monthlyBudgets = await DatabaseService.instance.getBudgetsForMonth(month);
    notifyListeners();
  }

  // Fungsi updateBudget sekarang memerlukan bulan
  Future<void> updateBudgetForMonth(
      int categoryId, DateTime month, double newBudget) async {
    await DatabaseService.instance
        .setBudgetForCategoryAndMonth(categoryId, month, newBudget);
    // Muat ulang budget untuk bulan tersebut agar UI terupdate
    await loadBudgetsForMonth(month);
  }
}

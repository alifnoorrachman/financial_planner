// lib/viewmodels/dashboard_viewmodel.dart

import 'package:fl_chart/fl_chart.dart'; // <-- Tambahkan import ini
import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import 'category_viewmodel.dart';

class DashboardViewModel extends ChangeNotifier {
  // --- State yang sudah ada ---
  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _currentMonthIncome = 0;
  double _currentMonthExpense = 0;
  Map<String, double> _expenseByCategory = {};

  // --- STATE BARU UNTUK LINE CHART ---
  List<FlSpot> _weeklyExpenseSpots = [];
  double _maxWeeklyExpense = 0; // Untuk menentukan tinggi sumbu Y pada chart

  // --- Getter yang sudah ada ---
  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get currentMonthIncome => _currentMonthIncome;
  double get currentMonthExpense => _currentMonthExpense;
  Map<String, double> get expenseByCategory => _expenseByCategory;

  // --- GETTER BARU ---
  List<FlSpot> get weeklyExpenseSpots => _weeklyExpenseSpots;
  double get maxWeeklyExpense => _maxWeeklyExpense;

  final CategoryViewModel categoryViewModel;

  DashboardViewModel({required this.categoryViewModel}) {
    loadData();
  }

  Future<void> loadData() async {
    final allTransactions = await DatabaseService.instance.getTransactions();
    final accounts = await DatabaseService.instance.getAllAccounts();

    // Reset nilai
    _totalIncome = 0;
    _totalExpense = 0;
    _currentMonthIncome = 0;
    _currentMonthExpense = 0;
    _expenseByCategory = {};
    _weeklyExpenseSpots = [];
    _maxWeeklyExpense = 0;

    // Inisialisasi kategori
    for (var category in categoryViewModel.expenseCategories) {
      _expenseByCategory[category.name] = 0.0;
    }

    // Kalkulasi total sepanjang waktu
    for (final Transaction transaction in allTransactions) {
      if (transaction.type == 'income') {
        _totalIncome += transaction.amount;
      } else {
        _totalExpense += transaction.amount;
      }
    }

    final now = DateTime.now();
    final monthlyTransactions = allTransactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    for (final Transaction transaction in monthlyTransactions) {
      if (transaction.type == 'income') {
        _currentMonthIncome += transaction.amount;
      } else {
        _currentMonthExpense += transaction.amount;
        if (_expenseByCategory.containsKey(transaction.category)) {
          _expenseByCategory.update(
            transaction.category,
            (value) => value + transaction.amount,
          );
        }
      }
    }

    // --- LOGIKA BARU: Menyiapkan data untuk Line Chart ---
    final today = DateTime(now.year, now.month, now.day);
    final weeklyExpenses = <double>[0, 0, 0, 0, 0, 0, 0]; // 7 hari

    for (final transaction in allTransactions) {
      if (transaction.type == 'expense') {
        final difference = today.difference(transaction.date).inDays;
        if (difference >= 0 && difference < 7) {
          weeklyExpenses[6 - difference] += transaction.amount;
        }
      }
    }

    for (int i = 0; i < 7; i++) {
      _weeklyExpenseSpots.add(FlSpot(i.toDouble(), weeklyExpenses[i]));
      if (weeklyExpenses[i] > _maxWeeklyExpense) {
        _maxWeeklyExpense = weeklyExpenses[i];
      }
    }
    // --- Akhir Logika Baru ---

    _totalBalance =
        accounts.fold(0, (sum, Account account) => sum + account.balance);

    notifyListeners();
  }
}

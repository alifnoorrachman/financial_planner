// lib/viewmodels/dashboard_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../services/database_service.dart';

class DashboardViewModel extends ChangeNotifier {
  double _totalBalance = 0;
  double _totalIncome = 0; // Total sepanjang waktu
  double _totalExpense = 0; // Total sepanjang waktu

  // STATE BARU UNTUK DATA BULANAN
  double _currentMonthIncome = 0;
  double _currentMonthExpense = 0;

  Map<String, double> _expenseByCategory = {};

  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;

  // GETTER BARU
  double get currentMonthIncome => _currentMonthIncome;
  double get currentMonthExpense => _currentMonthExpense;

  Map<String, double> get expenseByCategory => _expenseByCategory;

  DashboardViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    final allTransactions = await DatabaseService.instance.getTransactions();

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    _currentMonthIncome = 0;
    _currentMonthExpense = 0;

    final monthlyTransactions = allTransactions.where((t) {
      return t.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(endDate);
    }).toList();

    // --- PERBAIKAN 1 DI SINI ---
    for (final Transaction transaction in monthlyTransactions) {
      if (transaction.type == 'income') {
        _currentMonthIncome += transaction.amount;
      } else {
        _currentMonthExpense += transaction.amount;
      }
    }

    _totalIncome = 0;
    _totalExpense = 0;
    _expenseByCategory = {};

    // --- PERBAIKAN 2 DI SINI ---
    for (final Transaction transaction in allTransactions) {
      if (transaction.type == 'income') {
        _totalIncome += transaction.amount;
      } else {
        _totalExpense += transaction.amount;
        _expenseByCategory.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final accounts = await DatabaseService.instance.getAllAccounts();
    _totalBalance =
        accounts.fold(0, (sum, Account account) => sum + account.balance);

    notifyListeners();
  }
}

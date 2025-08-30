// lib/viewmodels/dashboard_viewmodel.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import 'category_viewmodel.dart';

class DashboardViewModel extends ChangeNotifier {
  DateTime _selectedMonth = DateTime.now();

  // --- KEMBALIKAN STATE TOTAL KESELURUHAN ---
  double _totalIncome = 0;
  double _totalExpense = 0;

  double _totalBalance = 0;
  double _currentMonthIncome = 0;
  double _currentMonthExpense = 0;
  Map<String, double> _expenseByCategory = {};
  List<FlSpot> _weeklyExpenseSpots = [];
  double _maxWeeklyExpense = 0;

  DateTime get selectedMonth => _selectedMonth;

  // --- KEMBALIKAN GETTER YANG HILANG ---
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;

  double get totalBalance => _totalBalance;
  double get currentMonthIncome => _currentMonthIncome;
  double get currentMonthExpense => _currentMonthExpense;
  Map<String, double> get expenseByCategory => _expenseByCategory;
  List<FlSpot> get weeklyExpenseSpots => _weeklyExpenseSpots;
  double get maxWeeklyExpense => _maxWeeklyExpense;

  final CategoryViewModel categoryViewModel;

  DashboardViewModel({required this.categoryViewModel}) {
    loadData();
  }

  Future<void> changeMonth(DateTime newMonth) async {
    final now = DateTime.now();
    if (newMonth.year > now.year ||
        (newMonth.year == now.year && newMonth.month > now.month)) {
      return;
    }
    _selectedMonth = newMonth;
    await loadData();
  }

  Future<void> loadData() async {
    final allTransactions = await DatabaseService.instance.getTransactions();
    final accounts = await DatabaseService.instance.getAllAccounts();

    // Reset semua nilai
    _totalIncome = 0;
    _totalExpense = 0;
    _currentMonthIncome = 0;
    _currentMonthExpense = 0;
    _expenseByCategory = {};
    _weeklyExpenseSpots = [];
    _maxWeeklyExpense = 0;

    // Inisialisasi kategori untuk bulan terpilih
    for (var category in categoryViewModel.expenseCategories) {
      _expenseByCategory[category.name] = 0.0;
    }

    // --- TAMBAHKAN KEMBALI LOGIKA UNTUK TOTAL KESELURUHAN ---
    for (final transaction in allTransactions) {
      if (transaction.type == 'income') {
        _totalIncome += transaction.amount;
      } else {
        _totalExpense += transaction.amount;
      }
    }

    // Filter transaksi berdasarkan bulan yang dipilih (_selectedMonth)
    final monthTransactions = allTransactions
        .where((t) =>
            t.date.year == _selectedMonth.year &&
            t.date.month == _selectedMonth.month)
        .toList();

    for (final Transaction transaction in monthTransactions) {
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

    _totalBalance = accounts.fold(0, (sum, account) => sum + account.balance);

    // Kalkulasi Line Chart (tidak berubah)
    final today =
        DateTime(_selectedMonth.year, _selectedMonth.month, _selectedMonth.day);
    final last7DaysTransactions = allTransactions.where((t) {
      return t.type == 'expense' &&
          t.date.isAfter(today.subtract(const Duration(days: 7))) &&
          t.date.isBefore(today.add(const Duration(days: 1)));
    }).toList();
    final weeklyExpenses = List.generate(7, (_) => 0.0);
    for (final transaction in last7DaysTransactions) {
      final difference = today
          .difference(DateTime(transaction.date.year, transaction.date.month,
              transaction.date.day))
          .inDays;
      if (difference >= 0 && difference < 7) {
        weeklyExpenses[6 - difference] += transaction.amount;
      }
    }
    for (int i = 0; i < 7; i++) {
      _weeklyExpenseSpots.add(FlSpot(i.toDouble(), weeklyExpenses[i]));
      if (weeklyExpenses[i] > _maxWeeklyExpense) {
        _maxWeeklyExpense = weeklyExpenses[i];
      }
    }

    notifyListeners();
  }
}

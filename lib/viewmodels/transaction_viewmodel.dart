// lib/viewmodels/transaction_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

enum TransactionFilter { all, today, thisWeek, thisMonth, custom }

class TransactionViewModel extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  TransactionFilter _currentFilter = TransactionFilter.all;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _categoryFilter;

  TransactionFilter get currentFilter => _currentFilter;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  Map<String, List<Transaction>> get groupedTransactions {
    final Map<String, List<Transaction>> groupedData = {};
    for (var transaction in _transactions) {
      final String monthYear =
          DateFormat('MMMM yyyy', 'id_ID').format(transaction.date);
      if (groupedData[monthYear] == null) {
        groupedData[monthYear] = [];
      }
      groupedData[monthYear]!.add(transaction);
    }
    return groupedData;
  }

  TransactionViewModel() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    switch (_currentFilter) {
      case TransactionFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case TransactionFilter.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case TransactionFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case TransactionFilter.custom:
        startDate = _filterStartDate;
        endDate = _filterEndDate;
        break;
      case TransactionFilter.all:
        break;
    }

    _transactions = await DatabaseService.instance.getTransactions(
      startDate: startDate,
      endDate: endDate,
      category: _categoryFilter,
    );
    notifyListeners();
  }

  Future<void> setCategoryFilter(String? category) async {
    _categoryFilter = category;
    _currentFilter = TransactionFilter.all;
    await loadTransactions();
  }

  // --- FUNGSI BARU DITAMBAHKAN DI SINI ---
  Future<void> loadTransactionsForCategoryInMonth(
      String category, DateTime month) async {
    _categoryFilter = category;
    _currentFilter = TransactionFilter.custom; // Set filter ke mode kustom
    // Tentukan awal dan akhir bulan dari parameter
    _filterStartDate = DateTime(month.year, month.month, 1);
    _filterEndDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    await loadTransactions();
  }
  // --- AKHIR FUNGSI BARU ---

  Future<void> changeFilter(TransactionFilter filter) async {
    _currentFilter = filter;
    if (filter != TransactionFilter.custom) {
      _filterStartDate = null;
      _filterEndDate = null;
    }
    await loadTransactions();
  }

  Future<void> setCustomDateRange(DateTimeRange range) async {
    _currentFilter = TransactionFilter.custom;
    _filterStartDate = range.start;
    _filterEndDate =
        DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
    await loadTransactions();
  }

  // --- PEMBARUAN PADA clearFilter ---
  Future<void> clearFilter() async {
    _currentFilter = TransactionFilter.all;
    _filterStartDate = null;
    _filterEndDate = null;
    _categoryFilter = null; // Memastikan _categoryFilter juga bersih
    await loadTransactions();
  }
  // --- AKHIR PEMBARUAN ---

  Future<void> handleTransaction({
    int? id,
    required int accountId,
    required String description,
    required double amount,
    required String category,
    required DateTime date,
    required String type,
  }) async {
    final newTransaction = Transaction(
      id: id,
      accountId: accountId,
      description: description,
      amount: amount,
      category: category,
      date: date,
      type: type,
    );

    if (id == null) {
      await DatabaseService.instance.insertTransaction(newTransaction);
      double adjustment = type == 'income' ? amount : -amount;
      await DatabaseService.instance
          .adjustAccountBalance(accountId, adjustment);
    } else {
      final oldTransaction =
          await DatabaseService.instance.getTransactionById(id);
      if (oldTransaction == null) return;

      double oldEffect = oldTransaction.type == 'income'
          ? oldTransaction.amount
          : -oldTransaction.amount;
      await DatabaseService.instance
          .adjustAccountBalance(oldTransaction.accountId, -oldEffect);

      double newEffect = type == 'income' ? amount : -amount;
      await DatabaseService.instance.adjustAccountBalance(accountId, newEffect);

      await DatabaseService.instance.updateTransaction(newTransaction);
    }

    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final transactionToDelete =
        await DatabaseService.instance.getTransactionById(id);
    if (transactionToDelete == null) return;

    double oldEffect = transactionToDelete.type == 'income'
        ? transactionToDelete.amount
        : -transactionToDelete.amount;
    await DatabaseService.instance
        .adjustAccountBalance(transactionToDelete.accountId, -oldEffect);

    await DatabaseService.instance.deleteTransaction(id);

    await loadTransactions();
  }
}

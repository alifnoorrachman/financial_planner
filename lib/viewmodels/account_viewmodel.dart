// lib/viewmodels/account_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/database_service.dart';

class AccountViewModel extends ChangeNotifier {
  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;

  AccountViewModel() {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    _accounts = await DatabaseService.instance.getAllAccounts();
    notifyListeners();
  }

  // Logika diubah: hanya butuh nama, saldo otomatis 0
  Future<void> addAccount(String name) async {
    final newAccount = Account(name: name, balance: 0.0);
    await DatabaseService.instance.insertAccount(newAccount);
    await loadAccounts();
  }
  
  // Tambahkan fungsi hapus untuk akun
  Future<void> deleteAccount(int id) async {
    await DatabaseService.instance.deleteAccount(id);
    await loadAccounts();
  }

  double get totalBalance {
    return _accounts.fold(0, (sum, account) => sum + account.balance);
  }
}
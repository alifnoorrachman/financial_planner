// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static sqflite.Database? _database;
  DatabaseService._init();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('financial_planner.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);
    return await sqflite.openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');
  }

  Future _upgradeDB(sqflite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN accountId INTEGER NOT NULL DEFAULT 0');
    }
  }

  // ===============================================================
  // --- FUNGSI YANG HILANG DITAMBAHKAN DI SINI ---
  Future<Transaction?> getTransactionById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    } else {
      return null;
    }
  }
  // ===============================================================

  // --- FUNGSI UNTUK TRANSAKSI ---
  Future<void> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    final db = await instance.database;
    String? whereString;
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereString = 'date BETWEEN ? AND ?';
      whereArgs.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    }

    if (category != null) {
      if (whereString == null) {
        whereString = 'category = ?';
      } else {
        whereString += ' AND category = ?';
      }
      whereArgs.add(category);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereString,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    await db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<void> deleteTransaction(int id) async {
    final db = await instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTransactionsByAccountId(int accountId) async {
    final db = await instance.database;
    await db.delete(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
  }

  // --- FUNGSI UNTUK AKUN ---
  Future<void> insertAccount(Account account) async {
    final db = await instance.database;
    await db.insert('accounts', account.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await instance.database;
    final result = await db.query('accounts', orderBy: 'name ASC');
    return result.map((json) => Account.fromMap(json)).toList();
  }

  Future<void> deleteAccount(int id) async {
    final db = await instance.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
    await db.delete('transactions', where: 'accountId = ?', whereArgs: [id]);
  }

  Future<void> adjustAccountBalance(
      int accountId, double amountAdjustment) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query('accounts', where: 'id = ?', whereArgs: [accountId]);
    if (maps.isNotEmpty) {
      double currentBalance = maps.first['balance'];
      double newBalance = currentBalance + amountAdjustment;
      await db.update('accounts', {'balance': newBalance},
          where: 'id = ?', whereArgs: [accountId]);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

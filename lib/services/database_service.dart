// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

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
        // NAIKKAN VERSI DATABASE ke 4 untuk tabel budget baru
        version: 4,
        onCreate: _createDB,
        onUpgrade: _upgradeDB);
  }

  Future _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE CASCADE
      )
    ''');
    await _createCategoriesTable(db);
    // Panggil fungsi untuk membuat tabel budget bulanan
    await _createMonthlyBudgetsTable(db);
  }

  Future _upgradeDB(sqflite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN accountId INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 3) {
      // Hapus kolom budget dari tabel categories karena sudah tidak relevan
      // (Ini adalah best practice, tapi untuk simplisitas kita biarkan saja dan tidak digunakan)
      await _createCategoriesTable(db);
    }
    // Jika upgrade dari versi < 4, buat tabel budget bulanan
    if (oldVersion < 4) {
      await _createMonthlyBudgetsTable(db);
    }
  }

  Future<void> _createCategoriesTable(sqflite.Database db) async {
    /* ... (Tidak berubah) */
  }
  // Removed unused _populateDefaultCategories method

  // --- FUNGSI BARU: MEMBUAT TABEL BUDGET BULANAN ---
  Future<void> _createMonthlyBudgetsTable(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE monthly_budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        amount REAL NOT NULL,
        UNIQUE (categoryId, month, year)
      )
    ''');
  }

  // --- FUNGSI BARU: Mengatur budget untuk kategori di bulan tertentu ---
  Future<void> setBudgetForCategoryAndMonth(
      int categoryId, DateTime month, double amount) async {
    final db = await instance.database;
    await db.insert(
      'monthly_budgets',
      {
        'categoryId': categoryId,
        'month': month.month,
        'year': month.year,
        'amount': amount,
      },
      // Jika sudah ada, update saja nilainya
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  // --- FUNGSI BARU: Mendapatkan semua budget untuk bulan tertentu ---
  Future<Map<int, double>> getBudgetsForMonth(DateTime month) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'monthly_budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month.month, month.year],
    );

    // Konversi hasil query ke format Map<categoryId, budgetAmount>
    return {for (var map in maps) map['categoryId']: map['amount']};
  }

  // --- FUNGSI BARU: Mengambil semua kategori dari DB ---
  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  // --- FUNGSI BARU: Memperbarui budget kategori ---
  Future<void> updateCategoryBudget(int id, double newBudget) async {
    final db = await instance.database;
    await db.update(
      'categories',
      {'budget': newBudget},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await instance.database;
    final maps =
        await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    } else {
      return null;
    }
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
      whereArgs
          .addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
    }
    if (category != null) {
      if (whereString == null) {
        whereString = 'category = ?';
      } else {
        whereString += ' AND category = ?';
      }
      whereArgs.add(category);
    }
    final List<Map<String, dynamic>> maps = await db.query('transactions',
        where: whereString, whereArgs: whereArgs, orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTransactionsByAccountId(int accountId) async {
    final db = await instance.database;
    await db
        .delete('transactions', where: 'accountId = ?', whereArgs: [accountId]);
  }

  Future<int> insertAccount(Account account) async {
    final db = await instance.database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return List.generate(maps.length, (i) {
      return Account.fromMap(maps[i]);
    });
  }

  Future<int> deleteAccount(int id) async {
    final db = await instance.database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> adjustAccountBalance(int accountId, double adjustment) async {
    final db = await instance.database;
    await db.rawUpdate(
      'UPDATE accounts SET balance = balance + ? WHERE id = ?',
      [adjustment, accountId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

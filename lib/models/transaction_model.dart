// lib/models/transaction_model.dart

class Transaction {
  final int? id;
  final int accountId; // <-- TAMBAHAN BARU: ID akun terkait
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String type; // 'income' atau 'expense'

  Transaction({
    this.id,
    required this.accountId, // <-- WAJIB diisi
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  // Perbarui juga fungsi toMap dan fromMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId, // <-- TAMBAHAN BARU
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'], // <-- TAMBAHAN BARU
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }
}
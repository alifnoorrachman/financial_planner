// lib/models/account_model.dart

class Account {
  final int? id; // <-- TAMBAHAN: ID dari database
  final String name;
  final double balance;

  Account({
    this.id, // <-- TAMBAHAN
    required this.name,
    required this.balance,
  });

  // --- TAMBAHAN BARU ---

  // Konverter: dari objek Account -> Map (untuk database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
    };
  }

  // Konverter: dari Map (dari database) -> objek Account
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
    );
  }
}
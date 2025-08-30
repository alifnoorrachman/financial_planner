// lib/models/category_model.dart

import 'package:flutter/material.dart';

class Category {
  final int? id; // Tambahkan ID untuk database
  final String name;
  final IconData icon;
  final String type;
  final double budget; // Properti baru untuk anggaran

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.budget = 0.0, // Default budget adalah 0
  });

  // Konversi dari Map (data database) ke objek Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      // Ikon disimpan sebagai string codepoint, perlu dikonversi kembali
      icon: IconData(map['iconCodepoint'], fontFamily: 'MaterialIcons'),
      type: map['type'],
      budget: map['budget'],
    );
  }

  // Konversi dari objek Category ke Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodepoint': icon.codePoint, // Simpan codepoint dari icon
      'type': type,
      'budget': budget,
    };
  }
}

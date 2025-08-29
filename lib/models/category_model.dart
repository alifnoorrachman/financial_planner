// lib/models/category_model.dart

import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final String type; // <-- TAMBAHAN BARU: 'income' atau 'expense'

  Category({
    required this.name,
    required this.icon,
    required this.type, // <-- WAJIB diisi
  });
}

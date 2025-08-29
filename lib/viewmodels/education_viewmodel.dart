// lib/viewmodels/education_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/education_model.dart';

class EducationViewModel extends ChangeNotifier {
  final List<EducationContent> _items = [
    EducationContent(
      title: 'Apa itu "Sinking Fund"?',
      content: 'Sinking fund (dana cadangan) adalah uang yang Anda sisihkan secara rutin untuk tujuan pengeluaran besar di masa depan. Contoh: dana untuk servis tahunan kendaraan, membeli HP baru, atau liburan. Dengan ini, Anda tidak akan kaget saat pengeluaran besar tiba.',
    ),
    EducationContent(
      title: 'Apa itu "Dana Darurat"?',
      content: 'Berbeda dari sinking fund, dana darurat adalah jaring pengaman untuk kejadian tak terduga yang mengganggu pemasukan, seperti kehilangan pekerjaan, sakit keras, atau bencana. Idealnya, besarnya 3-6 bulan total pengeluaran bulanan.',
    ),
    EducationContent(
      title: 'Tips: Metode Pencatatan "Zero-Based Budgeting"',
      content: 'Setiap Rupiah memiliki tujuan. Caranya: Total Pemasukan - Total Pengeluaran - Total Tabungan/Investasi = 0. Ini memaksa Anda untuk merencanakan alokasi setiap sen uang yang Anda miliki, sehingga tidak ada pemborosan.',
    ),
    EducationContent(
      title: 'Tips: Aturan 50/30/20',
      content: 'Metode populer untuk alokasi pendapatan:\n• 50% untuk Kebutuhan (Needs): Tagihan, bahan makanan, transportasi.\n• 30% untuk Keinginan (Wants): Hobi, makan di luar, hiburan.\n• 20% untuk Tabungan & Investasi (Savings): Dana darurat, investasi, melunasi utang.',
    ),
  ];

  List<EducationContent> get items => _items;
}
// lib/views/main_navigation_view.dart

import 'package:flutter/material.dart';
import 'account_view.dart';
import 'transaction_list_view.dart';
import 'charts_dashboard_view.dart';
import 'education_view.dart';
import 'add_transaction_view.dart'; // Impor halaman tambah transaksi

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});
  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    TransactionListView(),
    ChartsDashboardView(),
    EducationView(),
    AccountView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- PERUBAHAN UTAMA DI SINI ---
      body: _pages.elementAt(_selectedIndex),

      // 1. Tambahkan Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionView()),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      // 2. Atur lokasinya di tengah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 3. Ganti BottomNavigationBar menjadi BottomAppBar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Membuat lekukan untuk FAB
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.home_filled, index: 0, label: 'Home'),
            _buildNavItem(icon: Icons.pie_chart, index: 1, label: 'Dasbor'),
            const SizedBox(width: 48), // Ruang kosong untuk FAB
            _buildNavItem(icon: Icons.school, index: 2, label: 'Edukasi'),
            _buildNavItem(icon: Icons.account_balance, index: 3, label: 'Akun'),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat item navigasi
  Widget _buildNavItem(
      {required IconData icon, required int index, required String label}) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

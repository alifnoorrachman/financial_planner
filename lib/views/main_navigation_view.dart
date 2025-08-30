// lib/views/main_navigation_view.dart

import 'package:flutter/material.dart';
import 'account_view.dart';
import 'transaction_list_view.dart';
import 'budget_view.dart';
import 'add_transaction_view.dart'; // Impor halaman tambah transaksi
import 'dashboard_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});
  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    TransactionListView(),
    DashboardPage(),
    BudgetView(),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.home,
                    color: _selectedIndex == 0
                        ? Theme.of(context).primaryColor
                        : Colors.grey),
                onPressed: () => _onItemTapped(0)),
            IconButton(
                icon: Icon(Icons.pie_chart,
                    color: _selectedIndex == 1
                        ? Theme.of(context).primaryColor
                        : Colors.grey),
                onPressed: () => _onItemTapped(1)),
            const SizedBox(width: 48), // Ruang untuk FAB
            // --- PERBARUI IKON ---
            IconButton(
                icon: Icon(Icons.account_balance_wallet,
                    color: _selectedIndex == 2
                        ? Theme.of(context).primaryColor
                        : Colors.grey),
                onPressed: () => _onItemTapped(2)),
            IconButton(
                icon: Icon(Icons.person,
                    color: _selectedIndex == 3
                        ? Theme.of(context).primaryColor
                        : Colors.grey),
                onPressed: () => _onItemTapped(3)),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat item navigasi (removed as unused)
}

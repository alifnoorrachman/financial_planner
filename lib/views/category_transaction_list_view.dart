// lib/views/category_transaction_list_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import 'widgets/empty_state_widget.dart';

class CategoryTransactionListView extends StatefulWidget {
  final String categoryName;
  final DateTime selectedMonth; // <-- TERIMA PARAMETER BULAN

  const CategoryTransactionListView({
    super.key,
    required this.categoryName,
    required this.selectedMonth, // <-- WAJIB DIISI
  });

  @override
  State<CategoryTransactionListView> createState() =>
      _CategoryTransactionListViewState();
}

class _CategoryTransactionListViewState
    extends State<CategoryTransactionListView> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi baru di ViewModel dengan kategori DAN bulan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionViewModel>(context, listen: false)
          .loadTransactionsForCategoryInMonth(
              widget.categoryName, widget.selectedMonth);
    });
  }

  @override
  void dispose() {
    // Saat halaman ditutup, bersihkan semua filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionViewModel>(context, listen: false).clearFilter();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionVM = Provider.of<TransactionViewModel>(context);
    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);

    final categoryDetails = categoryVM.allCategories.firstWhere(
        (cat) => cat.name == widget.categoryName,
        orElse: () =>
            Category(name: 'Unknown', icon: Icons.help, type: 'expense'));

    return Scaffold(
      appBar: AppBar(
        // Judul AppBar diupdate untuk menampilkan bulan juga
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.categoryName),
            Text(
              DateFormat('MMMM yyyy', 'id_ID').format(widget.selectedMonth),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            )
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      // Halaman ini sekarang tidak lagi memerlukan filter chip
      body: _buildGroupedTransactionList(transactionVM, categoryDetails.icon),
    );
  }

  Widget _buildGroupedTransactionList(
      TransactionViewModel viewModel, IconData categoryIcon) {
    if (viewModel.transactions.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.money_off_csred_outlined,
        message: 'Tidak ada transaksi untuk periode ini.',
      );
    }

    // Karena sudah difilter di ViewModel, kita bisa langsung tampilkan
    final transactions = viewModel.transactions;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(categoryIcon, size: 20),
            ),
            title: Text(transaction.description),
            subtitle: Text(DateFormat('EEEE, d MMM yyyy', 'id_ID')
                .format(transaction.date)),
            trailing: Text(
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(transaction.amount),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}

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

  const CategoryTransactionListView({super.key, required this.categoryName});

  @override
  State<CategoryTransactionListView> createState() =>
      _CategoryTransactionListViewState();
}

class _CategoryTransactionListViewState
    extends State<CategoryTransactionListView> {
  @override
  void initState() {
    super.initState();
    // Saat halaman dibuka, langsung set filter kategori di ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionViewModel>(context, listen: false)
          .setCategoryFilter(widget.categoryName);
    });
  }

  @override
  void dispose() {
    // Saat halaman ditutup, bersihkan filter kategori agar tidak mempengaruhi halaman utama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionViewModel>(context, listen: false)
          .setCategoryFilter(null);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionVM = Provider.of<TransactionViewModel>(context);
    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);

    // Dapatkan detail (seperti ikon) dari kategori saat ini
    final categoryDetails = categoryVM.allCategories.firstWhere(
        (cat) => cat.name == widget.categoryName,
        orElse: () =>
            Category(name: 'Unknown', icon: Icons.help, type: 'expense'));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Widget untuk Filter Chip
          _buildFilterChips(transactionVM),
          Expanded(
            child: _buildGroupedTransactionList(
                transactionVM, categoryDetails.icon),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(TransactionViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FilterChip(
            label: const Text('Hari ini'),
            selected: viewModel.currentFilter == TransactionFilter.today,
            onSelected: (selected) {
              viewModel.changeFilter(TransactionFilter.today);
            },
          ),
          FilterChip(
            label: const Text('Minggu ini'),
            selected: viewModel.currentFilter == TransactionFilter.thisWeek,
            onSelected: (selected) {
              viewModel.changeFilter(TransactionFilter.thisWeek);
            },
          ),
          FilterChip(
            label: const Text('Bulan ini'),
            selected: viewModel.currentFilter == TransactionFilter.thisMonth,
            onSelected: (selected) {
              viewModel.changeFilter(TransactionFilter.thisMonth);
            },
          ),
        ],
      ),
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

    final groupedTransactions = viewModel.groupedTransactions;
    final months = groupedTransactions.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        final transactionsInMonth = groupedTransactions[month]!;

        // Hitung total pengeluaran untuk bulan ini
        final totalInMonth = transactionsInMonth.fold<double>(
            0, (sum, item) => sum + item.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    month,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    NumberFormat.currency(
                            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                        .format(totalInMonth),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
            ...transactionsInMonth.map((transaction) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(categoryIcon, size: 20),
                  ),
                  title: Text(transaction.description),
                  subtitle: Text(DateFormat('EEEE, d MMM', 'id_ID')
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
            }).toList(),
          ],
        );
      },
    );
  }
}

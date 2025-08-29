// lib/views/transaction_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'add_transaction_view.dart';
import 'widgets/filter_modal_widget.dart';

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal tidak menutupi keyboard
      builder: (ctx) {
        return const FilterModalWidget();
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    if (hour < 20) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final dashboardViewModel = Provider.of<DashboardViewModel>(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);
    final simpleCurrencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final groupedTransactions = transactionViewModel.groupedTransactions;
    final monthKeys = groupedTransactions.keys.toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.deepPurple,
                    child: Text('U',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Halo, Alif Noor Rachman!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_getGreeting(),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        color: Colors.grey[700], size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade400, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade200,
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(dashboardViewModel.totalBalance),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        title: 'Pemasukan',
                        amount: dashboardViewModel.totalIncome,
                        color: Colors.green,
                        icon: Icons.arrow_upward,
                        formatter: simpleCurrencyFormatter)),
                const SizedBox(width: 24),
                Expanded(
                    child: _buildInfoCard(
                        title: 'Pengeluaran',
                        amount: dashboardViewModel.totalExpense,
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                        formatter: simpleCurrencyFormatter)),
              ],
            ),
            const SizedBox(height: 12),

            // --- PERUBAHAN UI FILTER DI SINI ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent History',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.filter_list,
                      color: Colors.grey[700]), // Ganti ikon kalender ke filter
                  onPressed: () => _showFilterModal(context), // Panggil modal
                ),
              ],
            ),

            // Tampilkan info filter jika sedang aktif
            if (transactionViewModel.filterStartDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      padding: const EdgeInsets.all(8),
                      label: Text(
                        '${DateFormat.yMd('id_ID').format(transactionViewModel.filterStartDate!)} - ${DateFormat.yMd('id_ID').format(transactionViewModel.filterEndDate!)}',
                      ),
                      backgroundColor: Colors.deepPurple.shade50,
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      onDeleted: () => transactionViewModel.clearFilter(),
                    ),
                  ],
                ),
              ),
            // --- AKHIR PERUBAHAN UI FILTER ---

            const SizedBox(height: 8),

            if (groupedTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Center(
                  child: Text(
                    'Tidak ada riwayat transaksi.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthKeys.length,
                itemBuilder: (context, index) {
                  final month = monthKeys[index];
                  final transactionsInMonth = groupedTransactions[month]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          month,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactionsInMonth.length,
                          separatorBuilder: (context, index) => const Divider(
                              height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (context, tIndex) {
                            final Transaction transaction =
                                transactionsInMonth[tIndex];
                            final isExpense = transaction.type == 'expense';
                            final formattedAmount = NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: '',
                                    decimalDigits: 0)
                                .format(transaction.amount);
                            return ListTile(
                              leading: Icon(
                                  isExpense
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isExpense ? Colors.red : Colors.green),
                              title: Text(transaction.description,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(transaction.category),
                              trailing: Text(
                                '${isExpense ? '-' : '+'} Rp$formattedAmount',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isExpense ? Colors.black87 : Colors.green,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddTransactionView(
                                        transaction: transaction),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required NumberFormat formatter,
  }) {
    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha(26),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  formatter.format(amount),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

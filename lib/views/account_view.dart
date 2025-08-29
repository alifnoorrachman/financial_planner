// lib/views/account_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/account_viewmodel.dart';
import 'package:intl/intl.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  // Dialog diubah: hanya meminta Nama Akun
  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final viewModel = Provider.of<AccountViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buat Akun Baru'),
          content: TextField(
            controller: nameController,
            decoration:
                const InputDecoration(labelText: 'Nama Akun (e.g., Dompet)'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  viewModel.addAccount(name); // Panggil fungsi baru
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountViewModel>(context);
    final formattedTotal =
        NumberFormat.decimalPattern('id_ID').format(viewModel.totalBalance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
      ),
      body: Column(
        children: [
          // Card Total Saldo
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Saldo Akun:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Rp $formattedTotal',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(thickness: 1.0),
          ),
          // Daftar Akun
          Expanded(
            child: viewModel.accounts.isEmpty
                ? const Center(
                    child: Text('Belum ada akun. Tekan + untuk membuat.'))
                : ListView.builder(
                    itemCount: viewModel.accounts.length,
                    itemBuilder: (context, index) {
                      final account = viewModel.accounts[index];
                      final formattedBalance =
                          NumberFormat.decimalPattern('id_ID')
                              .format(account.balance);
                      // Gunakan Dismissible untuk fitur hapus
                      return Dismissible(
                        key: ValueKey(account.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.shade700,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          // Panggil semua ViewModel yang relevan
                          final accountVM = Provider.of<AccountViewModel>(
                              context,
                              listen: false);
                          final transactionVM =
                              Provider.of<TransactionViewModel>(context,
                                  listen: false);
                          final dashboardVM = Provider.of<DashboardViewModel>(
                              context,
                              listen: false);

                          // Jalankan hapus, lalu perbarui ViewModel lain
                          accountVM.deleteAccount(account.id!).then((_) {
                            transactionVM.loadTransactions();
                            dashboardVM.loadData();
                          });
                        },
                        child: ListTile(
                          leading:
                              const Icon(Icons.account_balance_wallet_outlined),
                          title: Text(account.name),
                          trailing: Text('Rp $formattedBalance',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        tooltip: 'Tambah Akun',
        child: const Icon(Icons.add),
      ),
    );
  }
}

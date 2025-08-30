// lib/views/budget_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'widgets/empty_state_widget.dart';

class BudgetView extends StatefulWidget {
  const BudgetView({super.key});

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  @override
  void initState() {
    super.initState();
    // Saat halaman pertama kali dibuka, muat budget untuk bulan yang aktif
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardVM =
          Provider.of<DashboardViewModel>(context, listen: false);
      Provider.of<CategoryViewModel>(context, listen: false)
          .loadBudgetsForMonth(dashboardVM.selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardViewModel, CategoryViewModel>(
      builder: (context, dashboardVM, categoryVM, child) {
        final expenseCategories = categoryVM.expenseCategories;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Anggaran Bulanan'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildMonthSelector(context, dashboardVM, categoryVM),
              Expanded(
                child: expenseCategories.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.category_outlined,
                        message: 'Tidak ada kategori pengeluaran.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: expenseCategories.length,
                        itemBuilder: (context, index) {
                          final category = expenseCategories[index];
                          return _buildBudgetCard(
                              context, category, dashboardVM, categoryVM);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector(BuildContext context,
      DashboardViewModel dashboardVM, CategoryViewModel categoryVM) {
    // ... (Sama seperti di dashboard_view, tapi dengan tambahan aksi memuat budget)
    final now = DateTime.now();
    final isCurrentMonth = dashboardVM.selectedMonth.year == now.year &&
        dashboardVM.selectedMonth.month == now.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 30),
            onPressed: () async {
              final prevMonth = DateTime(dashboardVM.selectedMonth.year,
                  dashboardVM.selectedMonth.month - 1);
              await dashboardVM.changeMonth(prevMonth);
              await categoryVM.loadBudgetsForMonth(prevMonth);
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(dashboardVM.selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                size: 30, color: isCurrentMonth ? Colors.grey : Colors.black),
            onPressed: isCurrentMonth
                ? null
                : () async {
                    final nextMonth = DateTime(dashboardVM.selectedMonth.year,
                        dashboardVM.selectedMonth.month + 1);
                    await dashboardVM.changeMonth(nextMonth);
                    await categoryVM.loadBudgetsForMonth(nextMonth);
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, Category category,
      DashboardViewModel dashboardVM, CategoryViewModel categoryVM) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Ambil budget bulanan dari CategoryViewModel
    final budgetAmount = categoryVM.getBudgetForCategory(category.id!);
    final spentAmount = dashboardVM.expenseByCategory[category.name] ?? 0.0;
    final progress =
        (budgetAmount > 0) ? (spentAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(child: Icon(category.icon, size: 20)),
        title: Text(category.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
                '${currencyFormatter.format(spentAmount)} / ${currencyFormatter.format(budgetAmount)}'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0
                    ? Colors.red.shade700
                    : (progress > 0.8
                        ? Colors.red.shade400
                        : (progress > 0.5
                            ? Colors.orange.shade400
                            : Colors.green.shade400)),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.edit_note),
        onTap: () =>
            _showEditBudgetDialog(context, category, dashboardVM.selectedMonth),
      ),
    );
  }

  void _showEditBudgetDialog(
      BuildContext context, Category category, DateTime selectedMonth) {
    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);
    final currentBudget = categoryVM.getBudgetForCategory(category.id!);
    final controller = TextEditingController(
      text: currentBudget > 0 ? currentBudget.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Anggaran ${category.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    labelText: 'Jumlah Anggaran (Rp)', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newBudget = double.tryParse(controller.text) ?? 0.0;
                categoryVM.updateBudgetForMonth(
                    category.id!, selectedMonth, newBudget);
                Navigator.of(ctx).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

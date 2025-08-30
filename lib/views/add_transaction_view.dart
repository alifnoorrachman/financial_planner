// lib/views/add_transaction_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/account_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class AddTransactionView extends StatefulWidget {
  final Transaction? transaction;
  const AddTransactionView({super.key, this.transaction});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  int? _selectedAccountId;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'expense';

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _descriptionController.text = t.description;
      _amountController.text = t.amount.toStringAsFixed(0);
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _transactionType = t.type;
      _selectedAccountId = t.accountId;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.transaction == null) {
      _updateDefaultCategory();
      if (_selectedAccountId == null) {
        final accounts =
            Provider.of<AccountViewModel>(context, listen: false).accounts;
        if (accounts.isNotEmpty) {
          _selectedAccountId = accounts.first.id;
        }
      }
    }
  }

  void _updateDefaultCategory() {
    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);
    List<Category> categoryList = _transactionType == 'income'
        ? categoryVM.incomeCategories
        : categoryVM.expenseCategories;

    if (categoryList.isNotEmpty) {
      if (!categoryList.any((cat) => cat.name == _selectedCategory)) {
        _selectedCategory = categoryList.first.name;
      }
    } else {
      _selectedCategory = null;
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

// Ganti seluruh fungsi _submitData dengan ini

  Future<void> _submitData() async {
    // <-- 1. Tambahkan 'async'
    // Cek jika form tidak valid, jangan lakukan apa-apa
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedAccountId == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pastikan semua field terisi.')),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    // Definisikan semua ViewModel di luar scope
    final transactionVM =
        Provider.of<TransactionViewModel>(context, listen: false);
    final accountVM = Provider.of<AccountViewModel>(context, listen: false);
    final dashboardVM = Provider.of<DashboardViewModel>(context, listen: false);

    // 2. Tambahkan 'await' untuk menunggu proses transaksi selesai
    await transactionVM.handleTransaction(
      id: widget.transaction?.id,
      accountId: _selectedAccountId!,
      description: _descriptionController.text,
      amount: amount,
      category: _selectedCategory!,
      date: _selectedDate,
      type: _transactionType,
    );

    // 3. Panggil load HANYA SETELAH await selesai
    accountVM.loadAccounts();
    dashboardVM.loadData();

    // 4. Tutup halaman setelah semuanya selesai
    if (mounted) {
      // Cek jika widget masih ada di tree
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);
    final accounts = Provider.of<AccountViewModel>(context).accounts;
    final activeCategoryList = _transactionType == 'income'
        ? categoryVM.incomeCategories
        : categoryVM.expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _submitData),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                  ButtonSegment(value: 'income', label: Text('Pemasukan')),
                ],
                selected: {_transactionType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _transactionType = newSelection.first;
                    final newCategoryList = _transactionType == 'income'
                        ? categoryVM.incomeCategories
                        : categoryVM.expenseCategories;
                    _selectedCategory = newCategoryList.isNotEmpty
                        ? newCategoryList.first.name
                        : null;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi (e.g., Makan siang)'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Deskripsi tidak boleh kosong'
                    : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Masukkan angka yang valid';
                  }
                  // --- TAMBAHAN VALIDASI ---
                  if (amount <= 0) {
                    return 'Jumlah harus lebih dari nol';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedAccountId,
                decoration: const InputDecoration(labelText: 'Dari/Ke Akun'),
                items: accounts.map((Account account) {
                  return DropdownMenuItem<int>(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedAccountId = newValue;
                  });
                },
                validator: (value) => value == null ? 'Pilih akun' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: activeCategoryList.map((Category category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Tanggal: ${DateFormat.yMd().format(_selectedDate)}'),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

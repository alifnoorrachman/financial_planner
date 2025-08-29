// lib/views/widgets/filter_modal_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/transaction_viewmodel.dart';

class FilterModalWidget extends StatefulWidget {
  const FilterModalWidget({super.key});

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late TransactionFilter _selectedFilter;
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
    _selectedFilter = viewModel.currentFilter;
    if (viewModel.filterStartDate != null && viewModel.filterEndDate != null) {
      _customDateRange = DateTimeRange(
        start: viewModel.filterStartDate!,
        end: viewModel.filterEndDate!,
      );
    }
  }

  Future<void> _pickDateRange() async {
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: _customDateRange ??
          DateTimeRange(start: DateTime.now(), end: DateTime.now()),
    );

    if (newDateRange != null) {
      setState(() {
        _customDateRange = newDateRange;
        _selectedFilter = TransactionFilter.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Transaksi',
              style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),

          // --- KODE DIRAPIKAN DI SINI ---
          _buildFilterOption(TransactionFilter.all, 'Semua'),
          _buildFilterOption(TransactionFilter.today, 'Hari Ini'),
          _buildFilterOption(TransactionFilter.thisWeek, 'Minggu Ini'),
          _buildFilterOption(TransactionFilter.thisMonth, 'Bulan Ini'),

          // Menggunakan RadioListTile juga untuk 'Rentang Kustom'
          RadioListTile<TransactionFilter>(
            title: const Text('Rentang Kustom'),
            subtitle: Text(_customDateRange == null
                ? 'Pilih tanggal'
                : '${DateFormat.yMd('id_ID').format(_customDateRange!.start)} - ${DateFormat.yMd('id_ID').format(_customDateRange!.end)}'),
            value: TransactionFilter.custom,
            groupValue: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
              // Langsung buka date picker jika opsi kustom dipilih
              _pickDateRange();
            },
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  viewModel.clearFilter();
                  Navigator.of(context).pop();
                },
                child: const Text('Hapus Filter'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_selectedFilter == TransactionFilter.custom) {
                    if (_customDateRange != null) {
                      viewModel.setCustomDateRange(_customDateRange!);
                    }
                  } else {
                    viewModel.changeFilter(_selectedFilter);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(TransactionFilter filter, String title) {
    return RadioListTile<TransactionFilter>(
      title: Text(title),
      value: filter,
      groupValue: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value!;
        });
      },
    );
  }
}

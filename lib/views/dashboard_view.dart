// lib/views/dashboard_view.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // <-- Tambahkan import ini
import 'category_transaction_list_view.dart';
import '../models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getCategoryDetails(
      BuildContext context, String categoryName) {
    // ... (kode ini tidak berubah)
    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);
    final category = categoryVM.allCategories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () =>
          Category(name: 'Lain-lain', icon: Icons.category, type: 'expense'),
    );
    const defaultColors = {
      'Utilities': Colors.orange,
      'Expenses': Colors.green,
      'Payments': Colors.blue,
      'Subscriptions': Colors.red,
      'Other': Colors.purple,
      'Makan & Minum': Colors.green,
      'Belanja': Colors.orange,
      'Transportasi': Colors.blue,
      'Tagihan': Colors.red,
      'Hiburan': Colors.purple,
      'Kesehatan': Colors.teal,
      'Investasi/Tabungan': Colors.indigo,
      'Tujuan Finansial': Colors.cyan,
      'Lain-lain': Colors.grey,
    };
    return {
      'icon': category.icon,
      'color': defaultColors[category.name] ?? Colors.black,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: RefreshIndicator(
            onRefresh: viewModel.loadData,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(),
                Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: PageView(
                        controller: _pageController,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildPieChartSection(context, viewModel),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildLineChartSection(context, viewModel),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 2,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Theme.of(context).primaryColor,
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                _buildCategoriesSection(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    // ... (kode ini tidak berubah)
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Text(
        'Insights',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- NAMA FUNGSI DIUBAH MENJADI LEBIH SPESIFIK ---
  Widget _buildPieChartSection(
      BuildContext context, DashboardViewModel viewModel) {
    // ... (kode ini sama seperti _buildChartSection sebelumnya)
    final totalExpense = viewModel.currentMonthExpense;
    final formattedTotal =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(totalExpense);
    final currentMonth = DateFormat('MMMM', 'id_ID').format(DateTime.now());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              viewModel.expenseByCategory.isEmpty
                  ? const Center(child: Text("Belum ada data pengeluaran."))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 8,
                        centerSpaceRadius: 70,
                        startDegreeOffset: -90,
                        sections: _getChartSections(context, viewModel),
                      ),
                    ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pengeluaran $currentMonth',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(formattedTotal,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET BARU UNTUK LINE CHART ---
  Widget _buildLineChartSection(
      BuildContext context, DashboardViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final now = DateTime.now();
                      final day =
                          now.subtract(Duration(days: 6 - value.toInt()));
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(DateFormat('E').format(day),
                            style: const TextStyle(fontSize: 12)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: viewModel.maxWeeklyExpense *
                  1.2, // Beri sedikit ruang di atas
              lineBarsData: [
                LineChartBarData(
                  spots: viewModel.weeklyExpenseSpots,
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Text('Pengeluaran 7 Hari Terakhir',
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  List<PieChartSectionData> _getChartSections(
      BuildContext context, DashboardViewModel viewModel) {
    // ... (kode ini tidak berubah)
    final totalExpense = viewModel.currentMonthExpense;
    if (totalExpense == 0) return [];
    final filteredCategories = viewModel.expenseByCategory.entries
        .where((entry) => entry.value > 0)
        .toList();
    return filteredCategories.map((entry) {
      final details = _getCategoryDetails(context, entry.key);
      final percentage = (entry.value / totalExpense) * 100;
      return PieChartSectionData(
        color: details['color'],
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 25,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildCategoriesSection(
      BuildContext context, DashboardViewModel viewModel) {
    // ... (kode ini tidak berubah)
    final categories = viewModel.expenseByCategory.entries.toList();
    final totalExpense = viewModel.currentMonthExpense;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori Pengeluaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final categoryEntry = categories[index];
              final details = _getCategoryDetails(context, categoryEntry.key);
              final percentage = totalExpense > 0
                  ? (categoryEntry.value / totalExpense) * 100
                  : 0;
              final categoryData = {
                'amount': categoryEntry.value,
                'percentage': percentage.toInt(),
                'name': categoryEntry.key,
                'icon': details['icon'],
                'color': details['color'],
              };
              // <-- PEMBARUAN: Kirim 'context' ke _buildCategoryCard
              return _buildCategoryCard(context, categoryData);
            },
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> category) {
    final formattedAmount =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(category['amount']);

    return InkWell(
      // Dibungkus dengan InkWell agar bisa diklik
      onTap: () {
        // Aksi navigasi ke halaman detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryTransactionListView(
              categoryName: category['name'],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: (category['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(category['icon'], color: category['color'], size: 24),
                Text(
                  '${category['percentage']}%',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedAmount,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  category['name'],
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

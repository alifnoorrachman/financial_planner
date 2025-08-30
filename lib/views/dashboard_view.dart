// lib/views/dashboard_view.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'category_transaction_list_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController();

  // TAMBAHKAN initState UNTUK MEMUAT BUDGET SAAT AWAL
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardVM =
          Provider.of<DashboardViewModel>(context, listen: false);
      Provider.of<CategoryViewModel>(context, listen: false)
          .loadBudgetsForMonth(dashboardVM.selectedMonth);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                // --- KONTEN UTAMA DENGAN FILTER BULAN ---
                Column(
                  children: [
                    _buildMonthSelector(context, viewModel), // <-- WIDGET BARU
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

  // PERBARUI _buildMonthSelector
  Widget _buildMonthSelector(
      BuildContext context, DashboardViewModel viewModel) {
    final now = DateTime.now();
    final isCurrentMonth = viewModel.selectedMonth.year == now.year &&
        viewModel.selectedMonth.month == now.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 30),
            onPressed: () async {
              final prevMonth = DateTime(viewModel.selectedMonth.year,
                  viewModel.selectedMonth.month - 1);
              await viewModel.changeMonth(prevMonth);
              // Muat juga budget untuk bulan yang baru
              await Provider.of<CategoryViewModel>(context, listen: false)
                  .loadBudgetsForMonth(prevMonth);
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(viewModel.selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                size: 30, color: isCurrentMonth ? Colors.grey : Colors.black),
            onPressed: isCurrentMonth
                ? null
                : () async {
                    final nextMonth = DateTime(viewModel.selectedMonth.year,
                        viewModel.selectedMonth.month + 1);
                    await viewModel.changeMonth(nextMonth);
                    // Muat juga budget untuk bulan yang baru
                    await Provider.of<CategoryViewModel>(context, listen: false)
                        .loadBudgetsForMonth(nextMonth);
                  },
          ),
        ],
      ),
    );
  }

  // --- Sisa kode tidak banyak berubah, hanya penyesuaian teks ---

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Text(
        'Insights',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPieChartSection(
      BuildContext context, DashboardViewModel viewModel) {
    final totalExpense = viewModel.currentMonthExpense;
    final formattedTotal =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(totalExpense);
    // Teks diupdate untuk menampilkan nama bulan yang dipilih
    final selectedMonthName =
        DateFormat('MMMM', 'id_ID').format(viewModel.selectedMonth);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              viewModel.expenseByCategory.isEmpty
                  ? const Center(child: Text("Tidak ada data pengeluaran."))
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
                  Text('Pengeluaran $selectedMonthName',
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
                      final day = viewModel.selectedMonth
                          .subtract(Duration(days: 6 - value.toInt()));
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
              maxY: (viewModel.maxWeeklyExpense == 0)
                  ? 10000
                  : viewModel.maxWeeklyExpense * 1.2,
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

  Map<String, dynamic> _getCategoryDetails(
      BuildContext context, String categoryName) {
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

  List<PieChartSectionData> _getChartSections(
      BuildContext context, DashboardViewModel viewModel) {
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

  // PERBARUI _buildCategoriesSection
  Widget _buildCategoriesSection(
      BuildContext context, DashboardViewModel viewModel) {
    final categoryVM = Provider.of<CategoryViewModel>(context);
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
          const Text('Anggaran Kategori',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryVM.expenseCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final category = categoryVM.expenseCategories[index];
              final spentAmount =
                  viewModel.expenseByCategory[category.name] ?? 0.0;
              final percentage =
                  totalExpense > 0 ? (spentAmount / totalExpense) * 100 : 0;

              // Ambil budget bulanan dari CategoryViewModel
              final budgetAmount =
                  categoryVM.getBudgetForCategory(category.id!);

              final categoryData = {
                'spent': spentAmount,
                'budget': budgetAmount, // Gunakan budget bulanan
                'percentage': percentage.toInt(),
                'name': category.name,
                'icon': category.icon,
                'color': _getCategoryDetails(context, category.name)['color'],
              };
              return _buildCategoryCard(context, categoryData);
            },
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> categoryData) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final double spent = categoryData['spent'];
    final double budget = categoryData['budget'];
    final progress = (budget > 0) ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return InkWell(
      onTap: () {
        // Ambil dashboard view model untuk mendapatkan bulan yang dipilih
        final dashboardVM =
            Provider.of<DashboardViewModel>(context, listen: false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryTransactionListView(
              categoryName: categoryData['name'],
              // --- TAMBAHKAN PARAMETER INI ---
              selectedMonth: dashboardVM.selectedMonth,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        // ... (sisa kode container tidak berubah)
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: (categoryData['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(categoryData['icon'],
                    color: categoryData['color'], size: 24),
                Text(
                  '${categoryData['percentage']}%',
                  style: TextStyle(
                      color: Colors.grey[700], fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryData['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                if (budget > 0) ...[
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress > 0.8
                          ? Colors.red
                          : (progress > 0.5 ? Colors.orange : Colors.green),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currencyFormatter.format(spent)} / ${currencyFormatter.format(budget)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    currencyFormatter.format(spent),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}

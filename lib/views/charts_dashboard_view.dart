// lib/views/charts_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class ChartsDashboardView extends StatelessWidget {
  const ChartsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Analitik'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.loadData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Judul untuk Grafik Pie Chart
            const Text(
              'Pengeluaran per Kategori',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grafik Pie Chart
            SizedBox(
              height: 200,
              child: viewModel.expenseByCategory.isEmpty
                  ? const Center(child: Text('Belum ada data pengeluaran.'))
                  : PieChart(
                      PieChartData(
                        sections:
                            _generateChartSections(viewModel.expenseByCategory),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Judul untuk Bar Chart
            const Text(
              'Arus Kas Bulan Ini',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: BarChart(
                    _generateBarData(viewModel),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mengubah data Map -> menjadi bagian-bagian PieChart
  List<PieChartSectionData> _generateChartSections(Map<String, double> data) {
    final List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.indigo
    ];
    int colorIndex = 0;
    return data.entries.map((entry) {
      final section = PieChartSectionData(
        color: colors[colorIndex++ % colors.length],
        value: entry.value,
        title: entry.key,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      return section;
    }).toList();
  }

  // Fungsi untuk membuat data Bar Chart
  BarChartData _generateBarData(DashboardViewModel viewModel) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (viewModel.currentMonthIncome > viewModel.currentMonthExpense
              ? viewModel.currentMonthIncome
              : viewModel.currentMonthExpense) *
          1.2,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style =
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
              String text;
              switch (value.toInt()) {
                case 0:
                  text = 'Pemasukan';
                  break;
                case 1:
                  text = 'Pengeluaran';
                  break;
                default:
                  text = '';
                  break;
              }
              return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(text, style: style));
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [
          BarChartRodData(
              toY: viewModel.currentMonthIncome,
              color: Colors.green,
              width: 25,
              borderRadius: BorderRadius.circular(4))
        ]),
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(
              toY: viewModel.currentMonthExpense,
              color: Colors.red,
              width: 25,
              borderRadius: BorderRadius.circular(4))
        ]),
      ],
    );
  }
}

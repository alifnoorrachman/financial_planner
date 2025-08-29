// lib/views/dashboard_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // State untuk melacak tab waktu yang aktif (Week, Month, Year)
  int _timeTabIndex = 1; // Default ke 'Month'

  // Data contoh untuk kategori. Di aplikasi nyata, ini akan datang dari ViewModel.
  final List<Map<String, dynamic>> categories = [
    {
      'amount': 447.84,
      'percentage': 36,
      'name': 'Utilities',
      'icon': Icons.lightbulb_outline,
      'color': Colors.orange
    },
    {
      'amount': 149.28,
      'percentage': 12,
      'name': 'Expenses',
      'icon': Icons.receipt_long,
      'color': Colors.green
    },
    {
      'amount': 248.8,
      'percentage': 20,
      'name': 'Payments',
      'icon': Icons.payment,
      'color': Colors.blue
    },
    {
      'amount': 99.52,
      'percentage': 8,
      'name': 'Subscriptions',
      'icon': Icons.subscriptions,
      'color': Colors.red
    },
    {
      'amount': 298.56,
      'percentage': 24,
      'name': 'Other',
      'icon': Icons.category,
      'color': Colors.purple
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        children: [
          _buildHeader(),
          _buildChartSection(),
          _buildCategoriesSection(),
        ],
      ),
    );
  }

  // Widget untuk header "Insights"
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Text(
        'Insights',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget untuk bagian diagram lingkaran (Donut Chart)
  Widget _buildChartSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 8, // Memberi jarak antar segmen
                      centerSpaceRadius: 70, // Ukuran lubang di tengah
                      startDegreeOffset: -90,
                      sections: _getChartSections(),
                    ),
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Spent this April',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text(
                        '\$1,244.65',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTimeToggle(),
          ],
        ),
      ),
    );
  }

  // Helper untuk membuat segmen-segmen chart dari data kategori
  List<PieChartSectionData> _getChartSections() {
    return categories.map((category) {
      return PieChartSectionData(
        color: category['color'],
        value: category['percentage'].toDouble(),
        title: '${category['percentage']}%',
        radius: 25,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // Widget untuk tombol toggle "Week, Month, Year"
  Widget _buildTimeToggle() {
    final List<String> labels = ['Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length, (index) {
          final bool isSelected = _timeTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _timeTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Widget untuk bagian bawah "Spending Categories"
  Widget _buildCategoriesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending Categories',
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
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          )
        ],
      ),
    );
  }

  // Widget untuk satu kartu kategori
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: category['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${category['amount']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${category['percentage']}%',
                  style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(category['icon'], color: category['color']),
              const SizedBox(height: 5),
              Text(category['name'], style: TextStyle(color: Colors.grey[800])),
            ],
          )
        ],
      ),
    );
  }
}

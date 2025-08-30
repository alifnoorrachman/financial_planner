// lib/views/onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'main_navigation_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  _OnboardingViewState createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Selamat Datang!',
      'description':
          'Aplikasi perencana keuangan untuk membantu Anda mengelola uang dengan lebih baik.',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'Lacak Transaksi',
      'description':
          'Catat setiap pemasukan dan pengeluaran Anda dengan mudah dan cepat.',
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'Lihat Laporan',
      'description':
          'Dapatkan wawasan tentang kebiasaan finansial Anda melalui laporan yang informatif.',
    },
  ];

  // --- 2. FUNGSI BARU UNTUK MENANDAI ONBOARDING SELESAI ---
  Future<void> _setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: _onboardingData[index],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage != _onboardingData.length - 1
                      ? TextButton(
                          onPressed: () {
                            // --- 3. PANGGIL FUNGSI SAAT SKIP ---
                            _setOnboardingComplete();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MainNavigationView(),
                              ),
                            );
                          },
                          child: const Text('Lewati'),
                        )
                      : const SizedBox(width: 60), // Placeholder
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  _currentPage != _onboardingData.length - 1
                      ? IconButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            // --- 4. PANGGIL FUNGSI SAAT SELESAI ---
                            _setOnboardingComplete();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MainNavigationView(),
                              ),
                            );
                          },
                          child: const Text('Mulai'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final Map<String, String> data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(data['image']!),
          const SizedBox(height: 40),
          Text(
            data['title']!,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            data['description']!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

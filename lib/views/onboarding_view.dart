// lib/views/onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// IMPORTANT: Adjust this import to point to your main app screen
import 'package:financial_planner_app/views/main_navigation_view.dart';

// A data model for our onboarding screen content
class OnboardingItem {
  final String imagePath;
  final String title;
  final String description;

  OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  // Controller to keep track of which page we're on
  final _pageController = PageController();

  // The list of content for each onboarding screen
  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      imagePath: 'assets/images/onboarding1.png',
      title: 'We really value your time',
      description:
          'The classes last for 60 minutes, you can schedule for any day.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding2.png',
      title: 'You will learn online',
      description: 'You won\'t need to spend money and time going to school.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding3.png',
      title: 'You will learn correctly',
      description:
          'Our teachers has a special international level certificate.',
    ),
  ];

  int _currentPage = 0;

  // This function is called when onboarding is finished or skipped
  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!context.mounted) return;

    // Navigate to your main app screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationView()),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple, // Dark background
      body: Stack(
        children: [
          // The main swipeable content
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingItems.length,
            physics: const NeverScrollableScrollPhysics(), // <-- ADD THIS LINE
            itemBuilder: (context, index) {
              final item = onboardingItems[index];
              return _buildPageContent(item);
            },
          ),

          // Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => _completeOnboarding(context),
              child: const Text('Skip',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),

          // Bottom controls (dots and button)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _buildBottomControls(),
          )
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingItem item) {
    return Column(
      children: [
        // Top part with the image/animation
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Image.asset(item.imagePath),
          ),
        ),
        // Bottom part with the text and button, inside a white container
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 24.0), // <-- Added this wrapper
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(), // Pushes the button and dots to the bottom
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    // Check if it's the last page
    bool isLastPage = _currentPage == onboardingItems.length - 1;

    return Container(
      color: Colors.white, // Ensure background is white
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          SmoothPageIndicator(
            controller: _pageController,
            count: onboardingItems.length,
            effect: const WormEffect(
              dotColor: Colors.grey,
              activeDotColor: Colors.black,
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (isLastPage) {
                // If it's the last page, complete onboarding
                _completeOnboarding(context);
              } else {
                // Otherwise, go to the next page
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
            // Change button text on the last page
            child: Text(isLastPage ? "Let's Started" : 'Continue Now'),
          ),
        ],
      ),
    );
  }
}

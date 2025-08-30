// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:financial_planner_app/main.dart';
import 'package:financial_planner_app/views/main_navigation_view.dart';

void main() {
  testWidgets('App starts and displays main navigation view',
      (WidgetTester tester) async {
    // Build aplikasi kita dan trigger sebuah frame.
    // Kita harus memberikan nilai untuk 'hasSeenOnboarding'.
    // Untuk tes ini, kita asumsikan pengguna sudah pernah melihat onboarding (true).
    await tester.pumpWidget(const MyApp(hasSeenOnboarding: true));

    // Lakukan pumpAndSettle untuk menunggu semua animasi/transisi selesai.
    await tester.pumpAndSettle();

    // Verifikasi bahwa halaman utama (MainNavigationView) muncul.
    // Ini adalah tes yang lebih relevan untuk aplikasi Anda.
    expect(find.byType(MainNavigationView), findsOneWidget);
  });
}

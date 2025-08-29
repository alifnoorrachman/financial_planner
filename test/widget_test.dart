// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Ganti 'financial_planner_app/main.dart' dengan path yang benar jika berbeda
import 'package:financial_planner_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Panggil MyApp tanpa parameter lagi.
    await tester.pumpWidget(const MyApp()); // <-- PERBAIKAN DI SINI

    // CATATAN: Kode di bawah ini kemungkinan besar akan GAGAL karena
    // aplikasi Anda tidak lagi memiliki counter.
    // Ini adalah sisa dari template default Flutter.

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

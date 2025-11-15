// This is a basic Flutter widget test for the Stock Management App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stock_management_app/main.dart';

void main() {
  testWidgets('Stock Management App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StockManagementApp());

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

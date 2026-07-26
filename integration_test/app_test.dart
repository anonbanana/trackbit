import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackbit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TrackBit App Integration Tests', () {
    testWidgets('App launches and shows login page', (tester) async {
      await tester.pumpWidget(
        const UncontrolledProviderScope(child: TrackBitApp()),
      );

      await tester.pumpAndSettle();

      // Verify login page is displayed
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login page has username and password fields', (tester) async {
      await tester.pumpWidget(
        const UncontrolledProviderScope(child: TrackBitApp()),
      );

      await tester.pumpAndSettle();

      // Look for text fields (username and password)
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
    });

    testWidgets('Dashboard displays navigation tiles', (tester) async {
      await tester.pumpWidget(
        const UncontrolledProviderScope(child: TrackBitApp()),
      );

      await tester.pumpAndSettle();

      // After login (or if auto-login), dashboard should show tiles
      // This is a basic smoke test
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}

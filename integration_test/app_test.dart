import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurant_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant App Integration Tests', () {
    testWidgets('Complete app flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the restaurant list screen and wait for data to load
      expect(find.text('Restaurant App'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify search icon is present and tap it
      expect(find.byIcon(Icons.search), findsOneWidget);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify we're on search screen
      expect(find.byType(TextField), findsOneWidget);

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate to settings using bottom navigation
      await tester.tap(find.byIcon(Icons.settings).last);  // Use last to get the bottom nav icon
      await tester.pumpAndSettle();

      // Verify we're on settings screen by checking AppBar title
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Pengaturan'),
        ),
        findsOneWidget,
      );

      // Test theme toggle
      final themeSwitch = find.byType(Switch).first;
      await tester.tap(themeSwitch);
      await tester.pumpAndSettle();

      // Navigate back to main screen using bottom navigation
      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();

      // Verify we're back on main screen
      expect(find.text('Restaurant App'), findsOneWidget);
    });
  });
}
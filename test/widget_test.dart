import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:amordaily/main.dart';
import 'package:amordaily/providers/love_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /* Mock SharedPreferences */
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test - verify navigation and main elements', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    /* Build our app and trigger a frame. */
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoveProvider(),
        child: const AmorDailyApp(),
      ),
    );

    /* Wait for initial data load - using pump(duration) instead of pumpAndSettle 
       because of infinite animations in HomeScreen */
    await tester.pump(const Duration(milliseconds: 100));

    /* Verify that we are on the Home screen and see "You & Partner" */
    expect(find.textContaining('You & Partner'), findsOneWidget);

    /* Verify we see the counter (0 days together initially) */
    /* Use find.textContaining if needed, but '0' is exact */
    expect(find.text('0'), findsOneWidget);

    /* Test Navigation to Anniversary Screen */
    final anniversaryTab = find.byIcon(Icons.calendar_today_rounded);
    if (anniversaryTab.evaluate().isNotEmpty) {
      await tester.tap(anniversaryTab);
      /* Pump again to transition */
      await tester.pump(const Duration(milliseconds: 500));

      /* Verify we see the anniversary title */
      expect(find.text('Anniversary'), findsOneWidget);
    }

    /* Test Navigation to Settings Screen */
    final settingsTab = find.byIcon(Icons.settings_rounded);
    if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await tester.pump(const Duration(milliseconds: 500));

      /* Verify we see Settings title */
      expect(find.text('Settings'), findsOneWidget);
    }
  });
}

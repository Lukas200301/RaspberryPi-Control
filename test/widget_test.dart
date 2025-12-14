// This is a basic Flutter widget test for RaspberryPi Control v3.0
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:RaspberryPi_Control/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RaspberryPiControlApp());

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that the app loads (home page should be visible)
    // We expect to find the Connections page as default for non-connected state
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
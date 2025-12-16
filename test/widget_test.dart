import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberrypi_control/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RaspberryPiControlApp()));

    // Verify app title is present
    expect(find.text('Dashboard'), findsOneWidget);
  });
}

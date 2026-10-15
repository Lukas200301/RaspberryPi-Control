import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raspberrypi_control/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const ProviderScope(child: RaspberryPiControlApp()));
    await tester.pump();

    // The app opens on the device list
    expect(find.text('Devices'), findsOneWidget);

    // Unmount so storage and probe timers are cancelled
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}

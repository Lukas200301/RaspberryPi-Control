import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/connections_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = StorageService();
  await storage.init();

  runApp(const ProviderScope(child: RaspberryPiControlApp()));
}

class RaspberryPiControlApp extends ConsumerWidget {
  const RaspberryPiControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Raspberry Pi Control',
      theme: themeState.themeData,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/connections': (context) => const ConnectionsScreen(),
      },
    );
  }
}

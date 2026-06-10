import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'data/services/widget_kit_service.dart';
import 'presentation/providers/tracker_provider.dart';
import 'presentation/screens/home_screen.dart';

/// Точка входу додатка BondDays
/// Ініціалізує сервіси, налаштовує тему та завантажує головний екран
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ініціалізуємо сервіси (їх як синглтони)
  final storageService = StorageService();
  final widgetKitService = WidgetKitService();

  // Ініціалізуємо локальне сховище
  await storageService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Надаємо сервіси для всього додатка
        Provider<StorageService>(create: (_) => storageService),
        Provider<WidgetKitService>(create: (_) => widgetKitService),
        // Надаємо TrackerProvider з залежностями від сервісів
        ChangeNotifierProvider(
          create: (_) => TrackerProvider(
            storageService: storageService,
            widgetKitService: widgetKitService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Корневий віджет додатка
/// Налаштовує Material Design тему та граф навігації
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BondDays - Event Tracker',
      theme: createAppTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

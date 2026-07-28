import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_text.dart';
import 'pages/analysis_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/smart_money_page.dart';
import 'state/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PolymarketEvApp()));
}

class PolymarketEvApp extends ConsumerWidget {
  const PolymarketEvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final darkMode = settings.valueOrNull?.darkMode ?? true;
    final text = AppText(settings.valueOrNull?.languageCode ?? 'en');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: text.appTitle,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const AppShell(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00C2A8),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: scheme.surfaceContainerLow,
      ),
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? const Color(0xFF0B0F14) : scheme.surface,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _pages = [
    HomePage(),
    AnalysisPage(),
    SmartMoneyPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final text = AppText(languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(text.appTitle),
        actions: [
          IconButton(
            tooltip: text.tradePlaceholder,
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(text.executionDisabled),
                content: Text(text.executionDisabledBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(text.ok),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.lock_outline),
          ),
        ],
      ),
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), label: text.home),
          NavigationDestination(icon: const Icon(Icons.analytics_outlined), label: text.analysis),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: text.smartMoney,
          ),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: text.settings),
        ],
      ),
    );
  }
}

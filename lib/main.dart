// Ponto de Entrada Principal do Sistema Suporte OS em Flutter/Dart - Tema Hyper POS

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/landing_page_screen.dart';
import 'screens/login_screen.dart';
import 'screens/saved_connections_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.loadPreferencesAndRestoreSession();

  // Manipulador de erros global para prevenir ecrãs brancos silenciosos
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0B0C0E),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF141519),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF6B00)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFFF6B00)),
              const SizedBox(height: 16),
              const Text(
                'Ocorreu um Erro no Sistema Suporte OS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const SuporteApp(),
    ),
  );
}

class SuporteApp extends StatelessWidget {
  const SuporteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    // Determina a rota inicial baseada na sessão do utilizador
    String initialRoute = '/';
    if (appState.isLoggedIn) {
      if (appState.isConnected) {
        initialRoute = '/dashboard';
      } else {
        initialRoute = '/connections';
      }
    }

    return MaterialApp(
      title: 'Suporte OS - Hyper POS Edition',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      
      // Tema Claro
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.compact,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B00),
          brightness: Brightness.light,
          primary: const Color(0xFFFF6B00),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),

      // Tema Escuro Extravagante estilo Hyper POS (Padrão)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.compact,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B00),
          brightness: Brightness.dark,
          primary: const Color(0xFFFF6B00),
          surface: const Color(0xFF141519),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0C0E),
      ),

      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(0.88),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LandingPageScreen(),
        '/login': (context) => const LoginScreen(),
        '/connections': (context) => const SavedConnectionsScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

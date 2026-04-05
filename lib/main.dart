import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/main_screen.dart';
import 'services/hive_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider()..loadTransactions(),
      child: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Finance Companion',
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              cardTheme: CardThemeData(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
              cardTheme: CardThemeData(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            home: Builder(builder: (context) {
              // Only trigger authentication if loaded and enabled
              if (!provider.isLoading && provider.isBiometricEnabled && !_isAuthenticated) {
                _handleBiometrics(context);
                return _buildAuthScreen();
              }
              
              if (provider.isLoading) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              return const MainScreen();
            }),
          );
        },
      ),
    );
  }

  void _handleBiometrics(BuildContext context) {
    if (_isAuthenticating) return;
    _isAuthenticating = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool authenticated = await AuthService.authenticate();
      if (authenticated) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      } else {
        _isAuthenticating = false;
      }
    });
  }

  Widget _buildAuthScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.teal),
            const SizedBox(height: 24),
            const Text('App Locked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleBiometrics(context),
              child: const Text('Unlock with Biometrics'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'services/hive_service.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

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
          final settings = HiveService.getSettingsBox();
          final bool isFirstRun = settings.get('isFirstRun', defaultValue: true);
          final bool isLoggedIn = settings.get('isLoggedIn', defaultValue: false);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fin Tracker',
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: Builder(builder: (context) {
              if (isFirstRun) {
                return const OnboardingScreen();
              }

              if (!isLoggedIn) {
                return const AuthScreen();
              }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF0097A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00897B).withAlpha(89),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_rounded, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text(
                'App Locked',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use your biometrics to unlock',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _handleBiometrics(context),
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text('Unlock with Biometrics'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

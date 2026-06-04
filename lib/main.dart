import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/_admin_route_wrapper.dart';
import 'screens/policy_screen.dart';


import 'services/state_provider.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootstrapApp());
}

/// Waits for storage + API init before showing the main UI (avoids LateInitializationError).
class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late final AppStateProvider _provider;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _provider = AppStateProvider();
    _initFuture = _provider.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Language Stories…',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ChangeNotifierProvider.value(
          value: _provider,
          child: const MyApp(),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
      final lightScheme = ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      );

      final darkScheme = ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      );

      return MaterialApp(
        title: 'Language Stories',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightScheme,
          inputDecorationTheme: const InputDecorationTheme(
            isDense: true,
            filled: true,
            fillColor: AppColors.background,
          ),
          textTheme: Typography.material2021().black.apply(
            fontFamily: null,
          ).apply(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkScheme,
          inputDecorationTheme: const InputDecorationTheme(
            isDense: true,
            filled: true,
            fillColor: AppDarkColors.surface,
          ),
        ),
        themeMode: ThemeMode.system,
        onGenerateRoute: (settings) {
        switch (settings.name) {
            case '/adminLogin':
              return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
            case '/admin':
              return MaterialPageRoute(builder: (_) => const AdminRouteWrapper());
            case '/policy':
              return MaterialPageRoute(builder: (_) => const PolicyScreen());
            case '/':
            default:
              return MaterialPageRoute(builder: (_) => const HomeScreen());
          }
        },
      );
  }
}



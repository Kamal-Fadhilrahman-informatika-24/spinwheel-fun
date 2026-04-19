// ============================================================
// main.dart
// Entry point — inisialisasi Supabase, Notifikasi, Provider
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/supabase_config.dart';
import 'config/app_theme.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';
import 'providers/spin_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock ke portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inisialisasi locale Indonesia untuk format tanggal
  await initializeDateFormatting('id_ID', null);

  // ── STEP 1: Inisialisasi Supabase ────────────────────────────
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // ── STEP 2: Inisialisasi Notifikasi ──────────────────────────
  await NotificationService().init();

  runApp(const SpinWheelApp());
}

class SpinWheelApp extends StatelessWidget {
  const SpinWheelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SpinProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            title: 'SpinWheel Fun',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProv.themeMode,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

// ── AuthGate: cek session dan listen perubahan auth ───────────
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Tampilkan loading saat cek session awal
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎯', style: TextStyle(fontSize: 52)),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('SpinWheel Fun',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatma (Tüm platformlarda güvenli başlatma)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[Main] Firebase başarıyla başlatıldı.');
  } catch (e) {
    debugPrint('[Main] Firebase başlatma bildirimi (Yerel mod devrede): $e');
  }

  // Veritabanı servisini başlat (Firestore + Reaktif Yerel Havuz)
  await DatabaseService().initialize();

  runApp(const KapsulDolapApp());
}

/// Kapsül Dolap Ana Uygulama Widget'ı
class KapsulDolapApp extends StatelessWidget {
  const KapsulDolapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAPSÜL - Kırklareli Local Fashion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RootGate(),
    );
  }
}

/// Kök Yönlendirici: Giriş Durumu Kontrolü
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  AppUser? _currentUser;

  void _handleLoginSuccess(AppUser user) {
    setState(() {
      _currentUser = user;
    });
  }

  void _handleLogout() async {
    await AuthService().signOut();
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return LoginScreen(onLoginSuccess: _handleLoginSuccess);
    }

    return MainAppShell(
      user: _currentUser!,
      onLogout: _handleLogout,
    );
  }
}

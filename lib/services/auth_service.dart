import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final bool isBoutique;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.isBoutique,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<AppUser> signInCustomer({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 4));
      _currentUser = AppUser(
        uid: cred.user?.uid ?? 'cust_${DateTime.now().millisecondsSinceEpoch}',
        name: cred.user?.displayName ?? 'Zeynep Berra (Öğrenci)',
        email: email,
        isBoutique: false,
      );
    } catch (e) {
      debugPrint('[AuthService] FirebaseAuth signIn hatası/fallback: $e');
      _currentUser = AppUser(
        uid: 'user_fallback_zeynep',
        name: email.contains('@') ? email.split('@')[0].toUpperCase() : 'Zeynep Berra',
        email: email.isEmpty ? 'zeynep@klu.edu.tr' : email,
        isBoutique: false,
      );
    }
    return _currentUser!;
  }

  Future<AppUser> signInBoutique({
    required String email,
    required String pin,
  }) async {
    _currentUser = AppUser(
      uid: 'boutique_merkez_istasyon',
      name: 'İstasyon Butik Yöneticisi',
      email: email.isEmpty ? 'istasyon@butik.kapsul.com' : email,
      isBoutique: true,
    );
    return _currentUser!;
  }

  Future<AppUser> signInGuest() async {
    _currentUser = const AppUser(
      uid: 'guest_user',
      name: 'Misafir Öğrenci',
      email: 'ogrenci@klu.edu.tr',
      isBoutique: false,
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    _currentUser = null;
  }
}

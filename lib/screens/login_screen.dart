import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final Function(AppUser user) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isBoutiqueTab = false;

  final TextEditingController _emailController = TextEditingController(
    text: 'zeynep@klu.edu.tr',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '123456',
  );
  final TextEditingController _boutiquePinController = TextEditingController(
    text: kBoutiquePin,
  );

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _boutiquePinController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_isLoading) return;

    if (_isBoutiqueTab &&
        _boutiquePinController.text.trim() != kBoutiquePin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatalı Butik Yetki PIN Kodu! (Demo PIN: 3939)'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      AppUser user;
      if (_isBoutiqueTab) {
        user = await AuthService().signInBoutique(
          email: _emailController.text.trim(),
          pin: _boutiquePinController.text.trim(),
        );
      } else {
        user = await AuthService().signInCustomer(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        widget.onLoginSuccess(user);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _quickFillStudent() {
    setState(() {
      _isBoutiqueTab = false;
      _emailController.text = 'zeynep@klu.edu.tr';
      _passwordController.text = '123456';
    });
    _submitLogin();
  }

  void _quickFillBoutique() {
    setState(() {
      _isBoutiqueTab = true;
      _emailController.text = 'istasyon@butik.kapsul.com';
      _boutiquePinController.text = kBoutiquePin;
    });
    _submitLogin();
  }

  Widget _tabButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentBeige : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: selected ? AppColors.background : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Arka plan lüks radial parıltı
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentBeige.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 24,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBeige.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  size: 13,
                                  color: AppColors.accentBeige,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isBoutiqueTab
                                      ? 'KIRKLARELİ BUTİK YÖNETİMİ'
                                      : 'KIRKLARELİ ÜNİVERSİTESİ • YEREL MODA',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentBeige,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'KAPSÜL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 7.0,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isBoutiqueTab
                              ? 'İstasyon Butik sipariş ve anlık kurye operasyon paneli.'
                              : 'Yerel butikleri kapına getiren hızlı kapsül dolap deneyimi.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Rol Seçim Sekmesi
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              _tabButton(
                                'MÜŞTERİ GİRİŞİ',
                                !_isBoutiqueTab,
                                () => setState(() => _isBoutiqueTab = false),
                              ),
                              _tabButton(
                                'BUTİK PANELİ',
                                _isBoutiqueTab,
                                () => setState(() => _isBoutiqueTab = true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_isBoutiqueTab) ...[
                          _buildWarmInput(
                            controller: _emailController,
                            hintText: 'Öğrenci / Müşteri E-posta',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _buildWarmInput(
                            controller: _passwordController,
                            hintText: 'Şifre',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.accentBeige.withValues(
                                  alpha: 0.6,
                                ),
                                size: 18,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ] else ...[
                          _buildWarmInput(
                            controller: _emailController,
                            hintText: 'Butik Kayıtlı E-posta',
                            icon: Icons.storefront_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _buildWarmInput(
                            controller: _boutiquePinController,
                            hintText: 'Yetkili Güvenlik PIN Kodu (3939)',
                            icon: Icons.verified_user_outlined,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        const SizedBox(height: 20),
                        // Giriş Yap Butonu
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.textLight,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentBeige.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _submitLogin,
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.background,
                                              ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _isBoutiqueTab
                                                ? 'BUTİK PANELİNE GİRİŞ'
                                                : 'GİRİŞ YAP',
                                            style: const TextStyle(
                                              color: AppColors.background,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: AppColors.background,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Hızlı Test / Hocaya Sunum Kısayolları
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    size: 14,
                                    color: AppColors.accentGold,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'HOCAYA SUNUM & TEST KISAYOLLARI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                      color: AppColors.accentBeige,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: _quickFillStudent,
                                      child: const Text(
                                        'Öğrenci Modu',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: _quickFillBoutique,
                                      child: const Text(
                                        'Butik Modu',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.accentBeige,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              final guest = await AuthService().signInGuest();
                              widget.onLoginSuccess(guest);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Şimdilik Giriş Yapmadan Butikleri Keşfet →',
                                style: TextStyle(
                                  color: AppColors.accentBeige,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarmInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textLight, fontSize: 13),
            cursorColor: AppColors.accentBeige,
            decoration: InputDecoration(
              icon: Icon(
                icon,
                color: AppColors.accentBeige.withValues(alpha: 0.7),
                size: 19,
              ),
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ),
    );
  }
}

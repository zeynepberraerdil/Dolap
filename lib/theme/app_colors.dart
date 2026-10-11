import 'package:flutter/material.dart';

/// Kapsül Dolap Lüks & Sıcak Editorial Renk Paleti
class AppColors {
  static const Color background = Color(0xFF121110);
  static const Color cardSurface = Color(0xFF1B1A18);
  static const Color cardSurfaceHover = Color(0xFF242220);
  static const Color accentBeige = Color(0xFFE8DACB);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentWarm = Color(0xFFC49A6C);
  static const Color textLight = Color(0xFFF7F5F2);
  static const Color textMuted = Color(0xFF9E9A93);
  static const Color textSubtle = Color(0xFF706C65);
  static const Color border = Color(0x28E8DACB);
  static const Color borderStrong = Color(0x50E8DACB);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color danger = Color(0xFFE57373);
}

/// Türkçe karakter büyüteç yardımcısı
String trUpper(String s) =>
    s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

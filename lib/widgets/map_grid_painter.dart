import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 24) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Yol çizgisi (Kırklareli Merkez -> Kayalı Kampüsü Rotası)
    final roadPaint = Paint()
      ..color = AppColors.accentBeige.withValues(alpha: 0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(25, 110)
      ..quadraticBezierTo(size.width * 0.45, 90, size.width * 0.55, 55)
      ..lineTo(size.width - 30, 45);

    canvas.drawPath(path, roadPaint);

    // Önemli noktalar (İstasyon Caddesi, Karakaş, Kampüs)
    final dotPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(25, 110), 4, dotPaint);
    canvas.drawCircle(Offset(size.width - 30, 45), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

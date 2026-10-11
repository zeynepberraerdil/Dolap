import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SafeImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SafeImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  String _cleanPath(String p) {
    // Türkçe karakter eşleme güvenliği
    return p
        .replaceAll('ayakkabıkahverengi', 'ayakkabikahverengi')
        .replaceAll('goldcicekdetaylıküpe', 'goldcicekdetaylikupe')
        .replaceAll('kahverengi_cıtcıtlıbody', 'kahverengi_citcitlibody')
        .replaceAll('trikogrihırka', 'trikogrihirka')
        .replaceAll('tüylüyumusakceket', 'tuyluyumusakceket');
  }

  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext context, Object error, StackTrace? stack) {
      return Container(
        width: width,
        height: height,
        color: AppColors.cardSurface,
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textMuted,
            size: 22,
          ),
        ),
      );
    }

    final sanitized = _cleanPath(path);

    if (sanitized.startsWith('assets/')) {
      return Image.asset(
        sanitized,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, st) {
          // İlk isimle tekrar dene
          return Image.asset(
            path,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: fallback,
          );
        },
      );
    }

    return Image.network(
      sanitized,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: fallback,
    );
  }
}

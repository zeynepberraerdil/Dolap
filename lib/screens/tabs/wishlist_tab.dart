import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/product.dart';
import '../../models/store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_hover_card.dart';
import '../../widgets/safe_image.dart';

class WishlistTab extends StatelessWidget {
  final List<Product> favoriteProducts;
  final List<Store> stores;
  final Function(Product product) onToggleFavorite;
  final Function(Product product) onProductTap;
  final Function(String message) onShowSnack;

  const WishlistTab({
    super.key,
    required this.favoriteProducts,
    required this.stores,
    required this.onToggleFavorite,
    required this.onProductTap,
    required this.onShowSnack,
  });

  String _getStoreName(String storeId) {
    try {
      return stores.firstWhere((s) => s.id == storeId).name;
    } catch (_) {
      return 'Kırklareli Butik';
    }
  }

  Future<void> _shareWishlist() async {
    final lines = favoriteProducts.map(
      (p) =>
          '• ${p.title} — ${p.price.toStringAsFixed(0)} TL (${_getStoreName(p.storeId)})',
    );
    final text = 'Kapsül Dolap İstek Listem:\n${lines.join('\n')}\n\nKırklareli Local Fashion Uygulamasından paylaşıldı.';
    await Clipboard.setData(ClipboardData(text: text));
    onShowSnack('Kapsül İstek Listen panoya kopyalandı!');
  }

  @override
  Widget build(BuildContext context) {
    if (favoriteProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: AppColors.accentBeige,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'İSTEK LİSTENİZ BOŞ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Beğendiğiniz kapsül parçaları kaydetmek için ürünlerin üzerindeki kalp simgesine dokunun.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FAVORİLER',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  '${favoriteProducts.length} Kapsül Parça Kaydedildi',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            AnimatedHoverCard(
              scaleAmount: 1.05,
              onTap: _shareWishlist,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.share_outlined,
                      size: 13,
                      color: AppColors.accentBeige,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'KAPSÜLÜ PAYLAŞ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: favoriteProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 18,
          ),
          itemBuilder: (ctx, i) {
            final p = favoriteProducts[i];
            return AnimatedHoverCard(
              scaleAmount: 1.03,
              elevationOffset: -4,
              onTap: () => onProductTap(p),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SafeImage(
                                path: p.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: AnimatedHoverCard(
                              scaleAmount: 1.15,
                              onTap: () => onToggleFavorite(p),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withValues(
                                    alpha: 0.85,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  size: 15,
                                  color: AppColors.accentBeige,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trUpper(_getStoreName(p.storeId)),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentBeige,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.price.toStringAsFixed(0)} TL',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

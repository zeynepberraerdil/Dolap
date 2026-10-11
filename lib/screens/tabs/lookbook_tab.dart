import 'package:flutter/material.dart';

import '../../models/store.dart';
import '../../models/product.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_hover_card.dart';
import '../../widgets/safe_image.dart';

class LookbookTab extends StatefulWidget {
  final Store store;
  final List<Product> products;
  final Set<String> favorites;
  final VoidCallback onBackToStores;
  final Function(Product product) onToggleFavorite;
  final Function(Product product) onProductTap;

  const LookbookTab({
    super.key,
    required this.store,
    required this.products,
    required this.favorites,
    required this.onBackToStores,
    required this.onToggleFavorite,
    required this.onProductTap,
  });

  @override
  State<LookbookTab> createState() => _LookbookTabState();
}

class _LookbookTabState extends State<LookbookTab> {
  String _selectedCategory = 'Tümü';

  List<String> get _categories {
    final set = {'Tümü'};
    for (final p in widget.products) {
      set.add(p.category);
    }
    return set.toList();
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Tümü') return widget.products;
    return widget.products
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final prods = _filteredProducts;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      children: [
        // Üst Butik Başlık Çubuğu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedHoverCard(
              scaleAmount: 1.05,
              onTap: widget.onBackToStores,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
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
                      Icons.arrow_back_ios_new,
                      size: 12,
                      color: AppColors.accentBeige,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'TÜM BUTİKLER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentBeige.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  trUpper(widget.store.name),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.accentBeige,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Kapsül Gardırop Rehberi Bilgi Kartı
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF262320), Color(0xFF1B1A18)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentBeige.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.accentBeige,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KAPSÜL GARDIROP KONSEPTİ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Her parça birbiriyle eşleşir. Detaylara dokunarak kapsül kombin sihirbazını keşfedin.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kategori Filtre Çipleri
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _categories.map((cat) {
              final isSel = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                      color: isSel
                          ? AppColors.background
                          : AppColors.textLight,
                    ),
                  ),
                  selected: isSel,
                  showCheckmark: false,
                  selectedColor: AppColors.accentBeige,
                  backgroundColor: AppColors.cardSurface,
                  side: BorderSide(
                    color: isSel ? AppColors.accentBeige : AppColors.border,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // Ürün Grid Listesi
        if (prods.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(
                'Bu kategoride ürün bulunmuyor.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 18,
            ),
            itemBuilder: (ctx, i) {
              final p = prods[i];
              final isFav = widget.favorites.contains(p.id);

              return AnimatedHoverCard(
                scaleAmount: 1.03,
                elevationOffset: -4,
                onTap: () => widget.onProductTap(p),
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
                            if (p.isOutOfStock)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'TÜKENDİ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: AnimatedHoverCard(
                                scaleAmount: 1.15,
                                onTap: () => widget.onToggleFavorite(p),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.background.withValues(
                                      alpha: 0.85,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 15,
                                    color: isFav
                                        ? AppColors.accentBeige
                                        : AppColors.textLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.accentBeige,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: p.isOutOfStock
                              ? AppColors.textMuted
                              : AppColors.textLight,
                          decoration:
                              p.isOutOfStock ? TextDecoration.lineThrough : null,
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

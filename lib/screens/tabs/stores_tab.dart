import 'package:flutter/material.dart';

import '../../models/store.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_hover_card.dart';
import '../../widgets/safe_image.dart';

class StoresTab extends StatelessWidget {
  final List<Store> stores;
  final String selectedDistrict;
  final String selectedAddress;
  final String searchQuery;
  final Function(String district) onDistrictSelected;
  final Function(String query) onSearchChanged;
  final Function(Store store) onStoreSelected;
  final VoidCallback onAddressChangeTap;

  const StoresTab({
    super.key,
    required this.stores,
    required this.selectedDistrict,
    required this.selectedAddress,
    required this.searchQuery,
    required this.onDistrictSelected,
    required this.onSearchChanged,
    required this.onStoreSelected,
    required this.onAddressChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      children: [
        // Üst Başlık & Adres
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KAPSÜL',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'KIRKLARELİ LOCAL BOUTIQUES',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: AppColors.accentBeige,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: AnimatedHoverCard(
                scaleAmount: 1.05,
                elevationOffset: -2,
                onTap: onAddressChangeTap,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        size: 13,
                        color: AppColors.accentBeige,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          selectedAddress.split('•')[0].trim(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Arama Kutusu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(color: AppColors.textLight, fontSize: 13),
            cursorColor: AppColors.accentBeige,
            decoration: const InputDecoration(
              icon: Icon(Icons.search, size: 18, color: AppColors.accentBeige),
              hintText: 'Butik veya ürün ara (Örn: Ceket, LCW, İstasyon)...',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // İlçe Filtreleri
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: ['Tümü', ...kDistricts].map((district) {
              final isSel = selectedDistrict == district;
              return Padding(
                padding: const EdgeInsets.only(right: 18),
                child: AnimatedHoverCard(
                  scaleAmount: 1.08,
                  elevationOffset: -2,
                  onTap: () => onDistrictSelected(district),
                  child: Column(
                    children: [
                      Text(
                        trUpper(district),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                          letterSpacing: 1.0,
                          color: isSel
                              ? AppColors.textLight
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isSel ? 20 : 0,
                        color: AppColors.accentBeige,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 22),

        // Butik Listesi
        if (stores.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: 40,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Seçili filtreye uygun butik bulunamadı.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          ...stores.map((store) {
            return AnimatedHoverCard(
              scaleAmount: 1.02,
              elevationOffset: -5,
              onTap: () => onStoreSelected(store),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: SafeImage(
                              path: store.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(
                                  alpha: 0.85,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    size: 12,
                                    color: AppColors.accentGold,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${trUpper(store.deliveryTime)} EXPRESS',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  trUpper(store.name),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.textLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 13,
                                      color: AppColors.accentGold,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${store.rating}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.accentGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${store.category} • ${trUpper(store.district)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.accentBeige,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Min. Sipariş: ${store.minOrder.toStringAsFixed(0)} TL • ${store.address}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

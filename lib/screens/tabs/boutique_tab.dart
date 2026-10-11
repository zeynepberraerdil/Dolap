import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/order_record.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_hover_card.dart';
import '../../widgets/safe_image.dart';

class BoutiqueDashboardTab extends StatefulWidget {
  final VoidCallback onSwitchToCustomerMode;
  final Function(String orderId) onOpenTracking;
  final Function(String message) onShowSnack;

  const BoutiqueDashboardTab({
    super.key,
    required this.onSwitchToCustomerMode,
    required this.onOpenTracking,
    required this.onShowSnack,
  });

  @override
  State<BoutiqueDashboardTab> createState() => _BoutiqueDashboardTabState();
}

class _BoutiqueDashboardTabState extends State<BoutiqueDashboardTab> {
  final Map<String, Timer> _activeTimers = {};

  @override
  void dispose() {
    for (final t in _activeTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  void _triggerCourierDispatch(OrderRecord order) {
    _activeTimers[order.orderId]?.cancel();
    int step = 1;
    DatabaseService().updateOrderStep(order.orderId, step);
    widget.onShowSnack('${order.orderId} onaylandı! Kurye yönlendirildi.');

    // 4 saniyede bir adımı ilerlet
    _activeTimers[order.orderId] = Timer.periodic(
      const Duration(seconds: 4),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        step++;
        DatabaseService().updateOrderStep(order.orderId, step);
        if (step >= 3) {
          timer.cancel();
        }
      },
    );
  }

  void _showAddProductDialog() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Dış Giyim');
    final descCtrl = TextEditingController(
      text: 'Kırklareli yerel butik özel tasarım koleksiyonu.',
    );
    String selectedImage = 'assets/ceket1.jpg';

    const sampleImages = [
      'assets/ceket1.jpg',
      'assets/cizgilikahverengipantalon.jpg',
      'assets/ayakkabikahverengi.jpg',
      'assets/kahverengiceket1.jpg',
      'assets/mavijean.jpg',
      'assets/trikogrihirka.jpg',
      'assets/kazak1.jpg',
      'assets/tuyluyumusakceket.jpg',
    ];

    const availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'Standart'];
    final Set<String> selectedSizes = {'S', 'M', 'L'};

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.add_business_outlined,
                    color: AppColors.accentBeige,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'YENİ ÜRÜN VİTRİNE KOY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İstasyon Butik vitrinine anında yeni kıyafet yükleyin.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Ürün Başlığı',
                        hintText: 'Örn: Kruvaze Kaşe Kaban',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (TL)',
                        hintText: 'Örn: 850',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryCtrl,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        hintText: 'Dış Giyim, Pantolon, Triko...',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Ürün Açıklaması & Kapsül Tavsiyesi',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Fotoğraf Seçin (Yerel Koleksiyon):',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: sampleImages.length,
                        itemBuilder: (context, idx) {
                          final img = sampleImages[idx];
                          final isSel = selectedImage == img;
                          return GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedImage = img),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.accentGold
                                      : AppColors.border,
                                  width: isSel ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: SafeImage(
                                  path: img,
                                  width: 45,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Beden Seçenekleri:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: availableSizes.map((s) {
                        final isSelected = selectedSizes.contains(s);
                        return FilterChip(
                          label: Text(
                            s,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: AppColors.accentBeige,
                          backgroundColor: AppColors.cardSurface,
                          onSelected: (val) {
                            setDialogState(() {
                              if (val) {
                                selectedSizes.add(s);
                              } else if (selectedSizes.length > 1) {
                                selectedSizes.remove(s);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBeige,
                    foregroundColor: AppColors.background,
                  ),
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    final price = double.tryParse(
                      priceCtrl.text.trim().replaceAll(',', '.'),
                    );
                    if (title.isEmpty || price == null || price <= 0) {
                      widget.onShowSnack('Lütfen geçerli başlık ve fiyat girin.');
                      return;
                    }

                    final newProd = Product(
                      id: 'k_custom_${DateTime.now().millisecondsSinceEpoch}',
                      storeId: kMainStoreId,
                      title: title,
                      category: categoryCtrl.text.trim().isEmpty
                          ? 'Casual'
                          : categoryCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      price: price,
                      imageUrl: selectedImage,
                      sizes: availableSizes
                          .where(selectedSizes.contains)
                          .toList(),
                      capsuleTip: 'İstasyon Butik özel kapsül parçası.',
                    );

                    DatabaseService().addProduct(newProd);
                    Navigator.pop(ctx);
                    widget.onShowSnack('${newProd.title} vitrine eklendi!');
                  },
                  child: const Text('VİTRİNE EKLE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderRecord>>(
      stream: DatabaseService().watchOrders(storeId: kMainStoreId),
      builder: (context, ordersSnap) {
        final orders = ordersSnap.data ?? [];
        final todayRevenue = orders
            .where((o) => o.isToday)
            .fold(0.0, (acc, o) => acc + o.totalAmount);
        final activeCount = orders.where((o) => o.step < 3).length;

        return StreamBuilder<List<Product>>(
          stream: DatabaseService().watchProducts(),
          builder: (context, prodsSnap) {
            final allProds = prodsSnap.data ?? [];
            final storeProds =
                allProds.where((p) => p.storeId == kMainStoreId).toList();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BUTİK YÖNETİMİ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppColors.textLight,
                      ),
                    ),
                    AnimatedHoverCard(
                      scaleAmount: 1.05,
                      onTap: widget.onSwitchToCustomerMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'MÜŞTERİ MODU',
                              style: TextStyle(
                                color: AppColors.accentBeige,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.accentBeige,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'İstasyon Butik • Kırklareli Merkez Şubesi',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),

                // İstatistik Satırı
                Row(
                  children: [
                    _statCard(
                      'BUGÜNKÜ CİRO',
                      '${todayRevenue.toStringAsFixed(0)} TL',
                      AppColors.accentGold,
                    ),
                    const SizedBox(width: 8),
                    _statCard(
                      'AKTİF SİPARİŞ',
                      '$activeCount Adet',
                      AppColors.textLight,
                    ),
                    const SizedBox(width: 8),
                    _statCard(
                      'VİTRİN ÜRÜNÜ',
                      '${storeProds.length} Parça',
                      AppColors.accentBeige,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Gelen Siparişler Başlığı
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GELEN SİPARİŞLER & OPERASYON',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.textLight,
                      ),
                    ),
                    Icon(
                      Icons.electric_scooter,
                      size: 16,
                      color: AppColors.accentGold,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (orders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Şu an bekleyen veya aktif sipariş bulunmuyor.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  ...orders.map((o) => _buildOrderCard(o)),

                const SizedBox(height: 24),

                // Mağaza Vitrini ve Envanteri
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MAĞAZA VİTRİNİ & ENVANTER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.textLight,
                      ),
                    ),
                    AnimatedHoverCard(
                      scaleAmount: 1.05,
                      onTap: _showAddProductDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentBeige,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add,
                              size: 13,
                              color: AppColors.background,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'YENİ ÜRÜN EKLE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...storeProds.map((p) => _buildInventoryItem(p)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(OrderRecord order) {
    final isDelivered = order.step >= 3;
    final isPending = order.step == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderId,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentGold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? Colors.green.withValues(alpha: 0.15)
                      : AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDelivered
                        ? Colors.greenAccent
                        : AppColors.accentGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (order.customerName.isNotEmpty)
            Text(
              '${order.customerName} • ${order.dateLabel}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          const SizedBox(height: 2),
          Text(
            'Ürünler: ${order.items.join(', ')}',
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Adres: ${order.address}',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
          if (order.tryAtDoor) ...[
            const SizedBox(height: 2),
            const Text(
              'Kapıda Dene Hizmeti Seçili',
              style: TextStyle(fontSize: 10, color: AppColors.accentGold),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.totalAmount.toStringAsFixed(0)} TL • ${order.paymentMethod}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textLight,
                ),
              ),
              if (isPending)
                AnimatedHoverCard(
                  scaleAmount: 1.05,
                  onTap: () => _triggerCourierDispatch(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentBeige,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.two_wheeler,
                          size: 13,
                          color: AppColors.background,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Kurye Çağır & Yola Çıkar',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: () => widget.onOpenTracking(order.orderId),
                  child: const Text(
                    'Canlı Takip Ekranı ➔',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(Product p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: p.isOutOfStock
              ? Colors.redAccent.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 45,
              height: 60,
              child: SafeImage(path: p.imageUrl, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.isOutOfStock
                        ? AppColors.textMuted
                        : AppColors.textLight,
                    decoration:
                        p.isOutOfStock ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.category} • Beden: ${p.sizes.join(", ")}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.price.toStringAsFixed(0)} TL',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: p.isOutOfStock
                ? 'Tekrar Satışa Aç'
                : 'Stok Bitti Olarak İşaretle',
            icon: Icon(
              p.isOutOfStock
                  ? Icons.remove_shopping_cart
                  : Icons.inventory_2_outlined,
              size: 20,
              color: p.isOutOfStock
                  ? Colors.orangeAccent
                  : AppColors.accentBeige,
            ),
            onPressed: () {
              DatabaseService().updateProductStock(p.id, !p.isOutOfStock);
              widget.onShowSnack(
                '${p.title} ${!p.isOutOfStock ? "stok bitti olarak işaretlendi." : "tekrar satışa açıldı."}',
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.redAccent,
            ),
            onPressed: () {
              DatabaseService().deleteProduct(p.id);
              widget.onShowSnack('${p.title} vitrinden kaldırıldı.');
            },
          ),
        ],
      ),
    );
  }
}

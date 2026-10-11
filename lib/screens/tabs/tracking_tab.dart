import 'package:flutter/material.dart';

import '../../models/order_record.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_hover_card.dart';
import '../../widgets/delivery_dialog.dart';
import '../../widgets/map_grid_painter.dart';

class TrackingTab extends StatefulWidget {
  final String? activeOrderId;
  final VoidCallback onBrowseStores;

  const TrackingTab({
    super.key,
    required this.activeOrderId,
    required this.onBrowseStores,
  });

  @override
  State<TrackingTab> createState() => _TrackingTabState();
}

class _TrackingTabState extends State<TrackingTab> {
  int? _lastStep;

  String _routeInfoFor(OrderRecord o) {
    final addr = o.address.split('•').first.trim();
    switch (o.step) {
      case 0:
        return '${o.storeName} siparişinizi hazırlıyor...';
      case 1:
        return 'Kurye ${o.courierName} paketi ${o.storeName} butiğinden teslim aldı, yola çıktı!';
      case 2:
        return '$addr yönünde hızla ilerleniyor.';
      default:
        return '$addr kapısına ulaşıldı.';
    }
  }

  String _etaFor(int step) => const ['25', '18', '8', '0'][step.clamp(0, 3)];

  void _handleStepChange(OrderRecord order) {
    if (_lastStep != null && _lastStep! < 3 && order.step >= 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDeliveryAnimation(context, orderId: order.orderId);
        }
      });
    }
    _lastStep = order.step;
  }

  void _callCourier(String name, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: AppColors.accentBeige, size: 20),
            const SizedBox(width: 8),
            Text(
              'KURYEYİ ARA',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        content: Text(
          '$name ($phone)\nKuryeniz Kırklareli içi teslimat rotasındadır.',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('KAPAT', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBeige,
              foregroundColor: AppColors.background,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kurye $name aranıyor... ($phone)'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('ŞİMDİ ARA'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.activeOrderId;
    if (id == null) {
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
                  Icons.local_shipping_outlined,
                  size: 40,
                  color: AppColors.accentBeige,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AKTİF SİPARİŞ BULUNMUYOR',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Verdiğiniz siparişlerin canlı kurye ve teslimat konumunu buradan anlık izleyebilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: widget.onBrowseStores,
                child: const Text('BUTİKLERİ KEŞFET'),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<OrderRecord?>(
      stream: DatabaseService().watchOrder(id),
      builder: (context, snap) {
        if (!snap.hasData || snap.data == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentBeige),
          );
        }

        final order = snap.data!;
        _handleStepChange(order);
        final step = order.step.clamp(0, 3);
        final addrShort = order.address.split('•').first.trim();

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
                      'TESLİMAT TAKİBİ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.orderId} • ${order.storeName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: step == 3
                        ? Colors.green.withValues(alpha: 0.2)
                        : AppColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: step == 3 ? Colors.green : AppColors.accentGold,
                    ),
                  ),
                  child: Text(
                    step == 3 ? 'Teslim Edildi' : 'Canlı Kurye',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: step == 3 ? Colors.greenAccent : AppColors.accentGold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Harita Çizimi
            Container(
              height: 155,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: MapGridPainter()),
                    ),
                    Positioned(
                      top: 12,
                      left: 14,
                      right: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.navigation_outlined,
                                    size: 12,
                                    color: AppColors.accentBeige,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'CANLI GPS ROTASI • KIRKLARELİ',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.accentBeige,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBeige.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  step == 0
                                      ? 'Butik Onayı Bekleniyor'
                                      : '${order.courierName} (${order.courierPlate})',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.accentBeige,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _routeInfoFor(order),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Canlı Motor İkonu
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      left: 30.0 + (step * 70.0),
                      bottom: 22.0 + (step * 8.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.two_wheeler,
                              size: 18,
                              color: AppColors.background,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Kurye',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kurye & Tahmini Süre Kartı
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TAHMİNİ TESLİMAT SÜRESİ',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.0,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step == 3 ? 'Paket Teslim Edildi ✓' : '${_etaFor(step)} Dakika',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: step == 3 ? Colors.greenAccent : AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                  if (step > 0 && step < 3)
                    AnimatedHoverCard(
                      scaleAmount: 1.06,
                      onTap: () => _callCourier(order.courierName, '0532 214 39 39'),
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
                            Icon(Icons.phone, size: 12, color: AppColors.background),
                            SizedBox(width: 4),
                            Text(
                              'KURYEYİ ARA',
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
            ),
            const SizedBox(height: 22),

            // 4 Adımlı İlerleme Çizelgesi
            _buildStep(
              'Sipariş Alındı',
              '${order.storeName} siparişinizi hazırlıyor.',
              0,
              step,
            ),
            _buildStep(
              'Paket Hazır & Kurye Aldı',
              'Kurye ${order.courierName} butikten hareket etti.',
              1,
              step,
            ),
            _buildStep(
              'Teslimat Yolunda',
              '$addrShort güzergahında ilerliyor.',
              2,
              step,
            ),
            _buildStep(
              'Teslim Edildi',
              'Paketiniz kapınıza güvenle ulaştı.',
              3,
              step,
              isLast: true,
            ),
            const SizedBox(height: 20),

            // Sipariş İçerik Özeti
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SİPARİŞ DETAYLARI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.accentBeige,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ürünler: ${order.items.join(', ')}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adres: ${order.address}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  if (order.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Teslimat Notu: ${order.note}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                  if (order.tryAtDoor) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Hizmet: Kapıda dene & geri ver seçili (Kurye 10 dk bekler)',
                      style: TextStyle(fontSize: 11, color: AppColors.accentGold),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Toplam: ${order.totalAmount.toStringAsFixed(0)} TL • Ödeme: ${order.paymentMethod}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentGold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep(
    String title,
    String desc,
    int step,
    int currentStep, {
    bool isLast = false,
  }) {
    final isDone = currentStep > step;
    final isCurrent = currentStep == step;
    final c = isDone || isCurrent
        ? AppColors.accentGold
        : AppColors.textMuted.withValues(alpha: 0.35);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isDone
                  ? Icons.check_circle
                  : (isCurrent
                        ? Icons.radio_button_checked
                        : Icons.circle_outlined),
              size: 16,
              color: c,
            ),
            if (!isLast)
              Container(width: 1, height: 36, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trUpper(title),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isDone || isCurrent
                      ? FontWeight.w800
                      : FontWeight.w500,
                  letterSpacing: 0.8,
                  color: isDone || isCurrent
                      ? AppColors.textLight
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

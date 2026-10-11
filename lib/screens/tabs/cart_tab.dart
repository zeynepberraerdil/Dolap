import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../models/store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_hover_card.dart';

class CartTab extends StatefulWidget {
  final List<CartItem> cart;
  final List<Store> stores;
  final bool tryAtDoor;
  final TextEditingController noteCtrl;
  final Function(bool value) onTryAtDoorChanged;
  final Function(CartItem item) onQuantityIncrement;
  final Function(CartItem item) onQuantityDecrement;
  final VoidCallback onCheckoutTap;
  final Function(String promoCode, double discount) onApplyCoupon;

  const CartTab({
    super.key,
    required this.cart,
    required this.stores,
    required this.tryAtDoor,
    required this.noteCtrl,
    required this.onTryAtDoorChanged,
    required this.onQuantityIncrement,
    required this.onQuantityDecrement,
    required this.onCheckoutTap,
    required this.onApplyCoupon,
  });

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final TextEditingController _couponCtrl = TextEditingController();
  String _appliedCode = '';
  double _discountAmount = 0.0;
  String? _couponError;

  double get _subtotal => widget.cart.fold(
    0.0,
    (acc, item) => acc + (item.price * item.quantity),
  );

  double get _deliveryFee => widget.cart.isEmpty ? 0.0 : 29.0;
  double get _tryAtDoorFee =>
      (widget.tryAtDoor && widget.cart.isNotEmpty) ? 25.0 : 0.0;
  double get _total =>
      (_subtotal - _discountAmount).clamp(0.0, double.infinity) +
      _deliveryFee +
      _tryAtDoorFee;

  void _applyCoupon() {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code == 'KLU10') {
      setState(() {
        _appliedCode = code;
        _discountAmount = _subtotal * 0.10;
        _couponError = null;
      });
      widget.onApplyCoupon(code, _discountAmount);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'KLU %10 Öğrenci İndirimi Başarıyla Uygulandı!',
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      );
    } else if (code == 'KAPSUL2026') {
      setState(() {
        _appliedCode = code;
        _discountAmount = 25.0;
        _couponError = null;
      });
      widget.onApplyCoupon(code, _discountAmount);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '25 TL Hoş Geldin İndirimi Uygulandı!',
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      );
    } else {
      setState(() {
        _couponError = 'Geçersiz kupon kodu (Dene: KLU10 veya KAPSUL2026)';
      });
    }
  }

  Widget _qtyButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _sumRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 13 : 11,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              letterSpacing: bold ? 1.0 : 0.3,
              color: bold ? AppColors.textLight : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 17 : 12,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              color: valueColor ??
                  (bold ? AppColors.accentGold : AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
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
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: AppColors.accentBeige,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SEPETİNİZ BOŞ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Kırklareli yerel butiklerinden beğendiğiniz parçaları ekleyin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SEPET',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppColors.textLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  widget.cart.first.storeName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentBeige,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ürün Listesi
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.cart.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.border, height: 18),
              itemBuilder: (ctx, i) {
                final item = widget.cart[i];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.storeName} • BEDEN: ${item.size}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _qtyButton(
                            '-',
                            () => widget.onQuantityDecrement(item),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              color: AppColors.accentBeige,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _qtyButton(
                            '+',
                            () => widget.onQuantityIncrement(item),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '${(item.price * item.quantity).toStringAsFixed(0)} TL',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Kapıda Dene & Geri Ver
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.door_front_door_outlined,
                  size: 20,
                  color: AppColors.accentBeige,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KAPIDA DENE & GERİ VER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.textLight,
                        ),
                      ),
                      Text(
                        'Kurye 10 dakika bekler, uymazsa anında iade (+25 TL)',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.tryAtDoor,
                  activeThumbColor: AppColors.accentBeige,
                  activeTrackColor: AppColors.accentBeige.withValues(alpha: 0.3),
                  onChanged: widget.onTryAtDoorChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Kupon Kodu Alanı (KLU Öğrenci İndirimi)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _couponError != null
                          ? Colors.redAccent
                          : AppColors.border,
                    ),
                  ),
                  child: TextField(
                    controller: _couponCtrl,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'İndirim Kodu (Örn: KLU10)...',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    foregroundColor: AppColors.accentBeige,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: _applyCoupon,
                  child: const Text('UYGULA', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
          if (_couponError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _couponError!,
                style: const TextStyle(fontSize: 10, color: Colors.redAccent),
              ),
            ),
          const SizedBox(height: 10),

          // Teslimat Notu
          TextField(
            controller: widget.noteCtrl,
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
            cursorColor: AppColors.accentBeige,
            decoration: const InputDecoration(
              hintText: 'Teslimat notu (Örn: Kayalı Yurdu B Blok)...',
              hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
              isDense: true,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.accentBeige),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tutar Özeti
          _sumRow('Ara Toplam', '${_subtotal.toStringAsFixed(0)} TL'),
          if (_discountAmount > 0)
            _sumRow(
              '$_appliedCode İndirimi',
              '-${_discountAmount.toStringAsFixed(0)} TL',
              valueColor: Colors.greenAccent,
            ),
          _sumRow('Kurye Teslimatı', '${_deliveryFee.toStringAsFixed(0)} TL'),
          if (widget.tryAtDoor)
            _sumRow(
              'Kapıda Dene & Geri Ver',
              '${_tryAtDoorFee.toStringAsFixed(0)} TL',
            ),
          const SizedBox(height: 4),
          _sumRow('TOPLAM', '${_total.toStringAsFixed(0)} TL', bold: true),
          const SizedBox(height: 14),

          // Siparişe Geç Butonu
          AnimatedHoverCard(
            scaleAmount: 1.02,
            onTap: widget.onCheckoutTap,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentBeige,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBeige.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'ÖDEMEYE GEÇ',
                  style: TextStyle(
                    color: AppColors.background,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

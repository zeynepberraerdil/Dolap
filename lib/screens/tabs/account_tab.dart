import 'package:flutter/material.dart';

import '../../models/order_record.dart';
import '../../models/store.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_hover_card.dart';

class AccountTab extends StatelessWidget {
  final AppUser user;
  final String selectedAddress;
  final List<String> addresses;
  final Function(String address) onSelectAddress;
  final VoidCallback onAddAddressTap;
  final VoidCallback onReturnToBoutique;
  final Function(String orderId) onOpenTracking;
  final VoidCallback onLogout;
  final Function(String message) onShowSnack;

  const AccountTab({
    super.key,
    required this.user,
    required this.selectedAddress,
    required this.addresses,
    required this.onSelectAddress,
    required this.onAddAddressTap,
    required this.onReturnToBoutique,
    required this.onOpenTracking,
    required this.onLogout,
    required this.onShowSnack,
  });

  void _showRegisterBoutiqueDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String district = kDistricts.first;

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
                    Icons.storefront_outlined,
                    color: AppColors.accentBeige,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'BUTİĞİNİ EKLE & KAZAN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kırklareli yerel tasarımcısı veya butik sahibi olarak Kapsül Dolap ağına katıl ve hemen satışa başla.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Butik / Marka Adı',
                        hintText: 'Örn: İstasyon Vintage',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'İlçe Seçimi:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: kDistricts.map((d) {
                        final sel = d == district;
                        return ChoiceChip(
                          label: Text(
                            d,
                            style: TextStyle(
                              fontSize: 10,
                              color: sel
                                  ? AppColors.background
                                  : AppColors.textLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          selected: sel,
                          showCheckmark: false,
                          selectedColor: AppColors.accentBeige,
                          backgroundColor: AppColors.cardSurface,
                          onSelected: (_) => setDialogState(() => district = d),
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
                    'Vazgeç',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBeige,
                    foregroundColor: AppColors.background,
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim().isEmpty
                        ? 'Öğrenci Kapsül Butik'
                        : nameCtrl.text.trim();
                    final newStore = Store(
                      id: 'store_user_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      district: district,
                      category: 'GENÇ TASARIM / YENİ',
                      deliveryTime: '20 dk',
                      rating: 5.0,
                      minOrder: 150.0,
                      imageUrl: 'assets/istasyon-butik-kart.png',
                      order: -DateTime.now().millisecondsSinceEpoch,
                    );
                    DatabaseService().registerStore(newStore);
                    Navigator.pop(ctx);
                    onShowSnack('$name başarıyla Kapsül vitrinine eklendi!');
                  },
                  child: const Text('ONAYLA & BAŞVUR'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.accentBeige, size: 22),
            SizedBox(width: 8),
            Text(
              'PROJE HAKKINDA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textLight,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kapsül Dolap • Kırklareli Yerel Hızlı Moda Platformu',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accentGold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bu proje, üniversite öğrencilerini ve yerel butikleri buluşturan, 30 dakikada kurye teslimatı ve "Kapıda Dene & Geri Ver" imkanı sunan yenilikçi bir kapsül gardırop e-ticaret uygulamasıdır.\n\n'
              '• Mimar: Flutter & Material 3\n'
              '• Veritabanı: Firebase Firestore (Reaktif Çift Mod)\n'
              '• Canlı Kurye GPS ve Sipariş Takibi\n'
              '• Çift Rol: Müşteri ve Butik Yönetim Paneli',
              style: TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBeige,
              foregroundColor: AppColors.background,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('TAMAM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFirestore = DatabaseService().isFirestoreActive;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HESABIM',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: AppColors.textLight,
              ),
            ),
            AnimatedHoverCard(
              scaleAmount: 1.08,
              onTap: onLogout,
              child: const Text(
                'ÇIKIŞ YAP',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Profil Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBeige,
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'Z',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBeige.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Kırklareli Üniversitesi • Öğrenci Hesabı',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentBeige,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Veritabanı Durumu Rozeti
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirestore ? Colors.greenAccent : AppColors.accentGold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isFirestore
                    ? 'Veritabanı: Cloud Firestore Canlı Senkronizasyon'
                    : 'Veritabanı: Reaktif Yerel Havuz (Offline Güvenli)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isFirestore ? Colors.greenAccent : AppColors.accentGold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Butik Yetkilisi ise Butik Paneline Dön
        if (user.isBoutique) ...[
          AnimatedHoverCard(
            scaleAmount: 1.02,
            onTap: onReturnToBoutique,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentBeige,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.storefront, color: AppColors.background, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'BUTİK YÖNETİM PANELİNE GEÇ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: AppColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Butiğini Ekle & Para Kazan
        AnimatedHoverCard(
          scaleAmount: 1.02,
          onTap: () => _showRegisterBoutiqueDialog(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2723), Color(0xFF1B1A18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.accentBeige.withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  color: AppColors.accentGold,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BUTİĞİNİ EKLE & KAZAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Kırklareli yerel satıcısı ol, 30 dakikada sipariş gönder.',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.accentBeige,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Kayıtlı Adres
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TESLİMAT ADRESİ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.textMuted,
              ),
            ),
            InkWell(
              onTap: onAddAddressTap,
              child: const Text(
                'Değiştir ➔',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentBeige,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.accentBeige,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Geçmiş Siparişler
        const Text(
          'GEÇMİŞ SİPARİŞLER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<OrderRecord>>(
          stream: DatabaseService().watchOrders(customerEmail: user.email),
          builder: (context, snap) {
            final orders = snap.data ?? [];
            if (orders.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Henüz geçmiş siparişiniz bulunmuyor.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              );
            }
            return Column(
              children: orders.map((o) {
                return AnimatedHoverCard(
                  scaleAmount: 1.02,
                  onTap: () => onOpenTracking(o.orderId),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              trUpper(o.storeName),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              '${o.totalAmount.toStringAsFixed(0)} TL',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${o.orderId} • ${o.dateLabel} • Durum: ${o.status}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 20),

        // Proje Hakkında Düğmesi
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.info_outline, size: 14, color: AppColors.accentBeige),
            label: const Text(
              'Kapsül Dolap Projesi Hakkında',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.accentBeige,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _showAboutProjectDialog(context),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/order_record.dart';
import '../models/product.dart';
import '../models/store.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_hover_card.dart';
import '../widgets/safe_image.dart';

import 'tabs/account_tab.dart';
import 'tabs/boutique_tab.dart';
import 'tabs/cart_tab.dart';
import 'tabs/lookbook_tab.dart';
import 'tabs/stores_tab.dart';
import 'tabs/tracking_tab.dart';
import 'tabs/wishlist_tab.dart';

class MainAppShell extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const MainAppShell({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;
  String _selectedDistrict = 'Tümü';
  String _selectedAddress = 'Kayalı Kampüsü, Öğrenci Yurdu • Merkez';
  String _searchQuery = '';
  late bool _isBoutiqueMode;

  String? _activeOrderId;
  final TextEditingController _noteCtrl = TextEditingController();
  String _selectedPaymentMethod = 'Online Kredi / Banka Kartı';
  double _appliedDiscount = 0.0;
  String _appliedCoupon = '';

  final Set<String> _favorites = {'k1', 'k7'};
  final List<CartItem> _cart = [];
  late Store _selectedStore;

  final List<String> _addresses = [
    'Kayalı Kampüsü, Öğrenci Yurdu • Merkez',
    'İstasyon Caddesi No:18 • Merkez',
    'İstanbul Caddesi, Çınaraltı • Lüleburgaz',
    'Hükümet Konağı Civarı • Pınarhisar',
    'Kırklareli Cad. Kale Yanı • Vize',
  ];

  @override
  void initState() {
    super.initState();
    _isBoutiqueMode = widget.user.isBoutique;
    final initialStores = DatabaseService().currentStores;
    _selectedStore = initialStores.isNotEmpty
        ? initialStores.first
        : Store(
            id: kMainStoreId,
            name: 'İstasyon Butik',
            district: 'Merkez',
            category: 'NEW ARRIVALS',
            deliveryTime: '25 dk',
            rating: 4.9,
            minOrder: 200,
            imageUrl: 'assets/istasyon-butik-kart.png',
          );

    if (_isBoutiqueMode) {
      _currentIndex = 5;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: error ? Colors.redAccent : null,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // Sepet İşlemleri
  double get _subtotal =>
      _cart.fold(0.0, (acc, item) => acc + (item.price * item.quantity));
  double get _deliveryFee => _cart.isEmpty ? 0.0 : 29.0;
  double get _tryAtDoorFee => (_tryAtDoor && _cart.isNotEmpty) ? 25.0 : 0.0;
  double get _total =>
      (_subtotal - _appliedDiscount).clamp(0.0, double.infinity) +
      _deliveryFee +
      _tryAtDoorFee;
  bool _tryAtDoor = false;

  Future<void> _addToCart(Product p, String size) async {
    if (p.isOutOfStock) return;

    if (_cart.isNotEmpty && _cart.first.storeId != p.storeId) {
      final changeOk = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text(
            'SEPETİ DEĞİŞTİR?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.textLight,
            ),
          ),
          content: Text(
            'Sepetinde ${_cart.first.storeName} butiğinin ürünleri var. '
            'Tek siparişte tek butikten hızlı kurye gönderimi yapılır. '
            'Sepet temizlensin mi?',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Vazgeç', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBeige,
                foregroundColor: AppColors.background,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('TEMİZLE & EKLE'),
            ),
          ],
        ),
      );
      if (changeOk != true || !mounted) return;
      setState(_cart.clear);
    }

    setState(() {
      final idx = _cart.indexWhere(
        (i) => i.title == p.title && i.size == size && i.storeId == p.storeId,
      );
      if (idx >= 0) {
        _cart[idx].quantity++;
      } else {
        _cart.add(
          CartItem(
            title: p.title,
            storeId: p.storeId,
            storeName: _getStoreName(p.storeId),
            size: size,
            price: p.price,
            imageUrl: p.imageUrl,
          ),
        );
      }
    });

    _snack('${p.title} sepete eklendi!');
  }

  String _getStoreName(String storeId) {
    try {
      return DatabaseService().currentStores.firstWhere((s) => s.id == storeId).name;
    } catch (_) {
      return 'Kırklareli Butik';
    }
  }

  void _placeOrder(String payment) {
    if (_cart.isEmpty) return;
    final first = _cart.first;
    final order = OrderRecord(
      orderId:
          '#KD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      storeId: first.storeId,
      storeName: first.storeName,
      totalAmount: _total,
      subtotal: _subtotal,
      discountAmount: _appliedDiscount,
      couponCode: _appliedCoupon,
      paymentMethod: payment,
      items: _cart
          .map((e) => '${e.title} [${e.size}] (x${e.quantity})')
          .toList(),
      customerName: widget.user.name,
      customerEmail: widget.user.email,
      address: _selectedAddress,
      note: _noteCtrl.text.trim(),
      tryAtDoor: _tryAtDoor,
      status: 'Hazırlanıyor (Butik Onayı Bekleniyor)',
      step: 0,
    );

    DatabaseService().createOrder(order);

    setState(() {
      _selectedPaymentMethod = payment;
      _activeOrderId = order.orderId;
      _currentIndex = 4;
      _cart.clear();
      _tryAtDoor = false;
      _noteCtrl.clear();
      _appliedDiscount = 0.0;
      _appliedCoupon = '';
    });

    _snack('Siparişiniz başarıyla alındı! Kurye rotası canlı takipte.');
  }

  void _showAddressModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TESLİMAT LOKASYONU SEÇİN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.accentBeige,
                  ),
                ),
                const SizedBox(height: 14),
                ..._addresses.map((addr) {
                  final isSelected = _selectedAddress == addr;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: isSelected
                          ? AppColors.accentGold
                          : AppColors.textMuted,
                      size: 20,
                    ),
                    title: Text(
                      addr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.textLight
                            : AppColors.textMuted,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: AppColors.accentGold,
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedAddress = addr);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCheckoutSheet() {
    if (_cart.isEmpty) return;

    Store store;
    try {
      store = DatabaseService().currentStores.firstWhere(
        (s) => s.id == _cart.first.storeId,
      );
    } catch (_) {
      store = _selectedStore;
    }

    if (_subtotal < store.minOrder) {
      _snack(
        '${store.name} için minimum sepet tutarı ${store.minOrder.toStringAsFixed(0)} TL olmalıdır! (Mevcut: ${_subtotal.toStringAsFixed(0)} TL)',
        error: true,
      );
      return;
    }

    String localPayment = _selectedPaymentMethod;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sCtx, setCheckoutState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SİPARİŞİ ONAYLA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppColors.textLight,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'TESLİMAT: $_selectedAddress',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ÖDEME YÖNTEMİ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final m in const [
                      'Online Kredi / Banka Kartı',
                      'Kapıda Kredi Kartı',
                      'Kapıda Nakit Ödeme',
                    ])
                      InkWell(
                        onTap: () => setCheckoutState(() => localPayment = m),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                m,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: m == localPayment
                                      ? AppColors.textLight
                                      : AppColors.textMuted,
                                  fontWeight: m == localPayment
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                              Icon(
                                m == localPayment
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 18,
                                color: m == localPayment
                                    ? AppColors.accentGold
                                    : AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Divider(color: AppColors.border, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOPLAM ÖDENECEK',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          '${_total.toStringAsFixed(0)} TL',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBeige,
                          foregroundColor: AppColors.background,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _placeOrder(localPayment);
                        },
                        child: const Text('SİPARİŞİ TAMAMLA'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showProductDetail(Product product) {
    String selectedSize = product.sizes.first;
    final allProds = DatabaseService().currentProducts;
    final matchedProducts =
        allProds.where((p) => product.matchWithIds.contains(p.id)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sCtx, setModal) {
            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        height: 250,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SafeImage(
                            path: product.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            trUpper(product.title),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                        Text(
                          '${product.price.toStringAsFixed(0)} TL',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentBeige.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: AppColors.accentGold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.capsuleTip,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.accentBeige,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'BEDEN SEÇİMİ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: product.sizes.map((s) {
                        final isSel = selectedSize == s;
                        return InkWell(
                          onTap: () => setModal(() => selectedSize = s),
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 50),
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.accentBeige
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSel
                                    ? AppColors.accentBeige
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSel
                                      ? AppColors.background
                                      : AppColors.textLight,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (matchedProducts.isNotEmpty) ...[
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppColors.accentGold,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'KAPSÜL KOMBİN SİHİRBAZI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Bu parça ile kusursuz uyum sağlayan Kırklareli yerel tasarımları:',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: matchedProducts.length,
                          itemBuilder: (_, idx) {
                            final match = matchedProducts[idx];
                            return AnimatedHoverCard(
                              scaleAmount: 1.05,
                              onTap: match.isOutOfStock
                                  ? null
                                  : () => _addToCart(match, match.sizes.first),
                              child: Container(
                                width: 230,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: SizedBox(
                                        width: 50,
                                        height: 75,
                                        child: SafeImage(
                                          path: match.imageUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            match.title,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textLight,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${match.price.toStringAsFixed(0)} TL',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.accentGold,
                                            ),
                                          ),
                                          Text(
                                            match.isOutOfStock
                                                ? 'Tükendi'
                                                : '+ Kombine Ekle',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: AppColors.accentBeige,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBeige,
                          foregroundColor: AppColors.background,
                        ),
                        onPressed: product.isOutOfStock
                            ? null
                            : () {
                                Navigator.pop(ctx);
                                _addToCart(product, selectedSize);
                              },
                        child: Text(
                          product.isOutOfStock ? 'STOK TÜKENDİ' : 'SEPETE EKLE',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Store>>(
      stream: DatabaseService().watchStores(),
      builder: (context, storesSnap) {
        final stores = storesSnap.data ?? DatabaseService().currentStores;

        // Arama ve ilçe filtreleri
        final filteredStores = stores.where((s) {
          final matchesDistrict = _selectedDistrict == 'Tümü' ||
              s.district == _selectedDistrict;
          if (!matchesDistrict) return false;
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          final inStore = s.name.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q);
          return inStore;
        }).toList();

        return StreamBuilder<List<Product>>(
          stream: DatabaseService().watchProducts(),
          builder: (context, prodsSnap) {
            final allProds = prodsSnap.data ?? DatabaseService().currentProducts;
            final storeProducts = allProds
                .where((p) => p.storeId == _selectedStore.id)
                .toList();
            final favProducts =
                allProds.where((p) => _favorites.contains(p.id)).toList();

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    StoresTab(
                      stores: filteredStores,
                      selectedDistrict: _selectedDistrict,
                      selectedAddress: _selectedAddress,
                      searchQuery: _searchQuery,
                      onDistrictSelected: (d) =>
                          setState(() => _selectedDistrict = d),
                      onSearchChanged: (q) =>
                          setState(() => _searchQuery = q.trim()),
                      onStoreSelected: (s) {
                        setState(() {
                          _selectedStore = s;
                          _currentIndex = 1;
                        });
                      },
                      onAddressChangeTap: _showAddressModal,
                    ),
                    LookbookTab(
                      store: _selectedStore,
                      products: storeProducts,
                      favorites: _favorites,
                      onBackToStores: () => setState(() => _currentIndex = 0),
                      onToggleFavorite: (p) {
                        setState(() {
                          if (_favorites.contains(p.id)) {
                            _favorites.remove(p.id);
                          } else {
                            _favorites.add(p.id);
                          }
                        });
                      },
                      onProductTap: _showProductDetail,
                    ),
                    WishlistTab(
                      favoriteProducts: favProducts,
                      stores: stores,
                      onToggleFavorite: (p) {
                        setState(() => _favorites.remove(p.id));
                      },
                      onProductTap: _showProductDetail,
                      onShowSnack: _snack,
                    ),
                    CartTab(
                      cart: _cart,
                      stores: stores,
                      tryAtDoor: _tryAtDoor,
                      noteCtrl: _noteCtrl,
                      onTryAtDoorChanged: (v) => setState(() => _tryAtDoor = v),
                      onQuantityIncrement: (item) {
                        setState(() => item.quantity++);
                      },
                      onQuantityDecrement: (item) {
                        setState(() {
                          if (item.quantity > 1) {
                            item.quantity--;
                          } else {
                            _cart.remove(item);
                          }
                        });
                      },
                      onCheckoutTap: _showCheckoutSheet,
                      onApplyCoupon: (code, disc) {
                        setState(() {
                          _appliedCoupon = code;
                          _appliedDiscount = disc;
                        });
                      },
                    ),
                    TrackingTab(
                      activeOrderId: _activeOrderId,
                      onBrowseStores: () => setState(() => _currentIndex = 0),
                    ),
                    _isBoutiqueMode
                        ? BoutiqueDashboardTab(
                            onSwitchToCustomerMode: () {
                              setState(() => _isBoutiqueMode = false);
                            },
                            onOpenTracking: (oid) {
                              setState(() {
                                _activeOrderId = oid;
                                _currentIndex = 4;
                              });
                            },
                            onShowSnack: _snack,
                          )
                        : AccountTab(
                            user: widget.user,
                            selectedAddress: _selectedAddress,
                            addresses: _addresses,
                            onSelectAddress: (addr) =>
                                setState(() => _selectedAddress = addr),
                            onAddAddressTap: _showAddressModal,
                            onReturnToBoutique: () {
                              setState(() => _isBoutiqueMode = true);
                            },
                            onOpenTracking: (oid) {
                              setState(() {
                                _activeOrderId = oid;
                                _currentIndex = 4;
                              });
                            },
                            onLogout: widget.onLogout,
                            onShowSnack: _snack,
                          ),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 0.8),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.accentGold,
                  unselectedItemColor:
                      AppColors.textMuted.withValues(alpha: 0.6),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedFontSize: 10,
                  unselectedFontSize: 10,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_outlined, size: 20),
                      activeIcon: Icon(Icons.grid_view, size: 20),
                      label: 'Butikler',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.checkroom_outlined, size: 20),
                      activeIcon: Icon(Icons.checkroom, size: 20),
                      label: 'Lookbook',
                    ),
                    BottomNavigationBarItem(
                      icon: Badge(
                        label: Text(
                          '${_favorites.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.background,
                          ),
                        ),
                        isLabelVisible: _favorites.isNotEmpty,
                        backgroundColor: AppColors.accentGold,
                        child: const Icon(Icons.favorite_border, size: 20),
                      ),
                      activeIcon: const Icon(Icons.favorite, size: 20),
                      label: 'Favoriler',
                    ),
                    BottomNavigationBarItem(
                      icon: Badge(
                        label: Text(
                          '${_cart.fold<int>(0, (acc, i) => acc + i.quantity)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.background,
                          ),
                        ),
                        isLabelVisible: _cart.isNotEmpty,
                        backgroundColor: AppColors.accentGold,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 20,
                        ),
                      ),
                      activeIcon: const Icon(Icons.shopping_bag, size: 20),
                      label: 'Sepet',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.local_shipping_outlined, size: 20),
                      activeIcon: Icon(Icons.local_shipping, size: 20),
                      label: 'Takip',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        _isBoutiqueMode
                            ? Icons.storefront_outlined
                            : Icons.person_outline,
                        size: 20,
                      ),
                      activeIcon: Icon(
                        _isBoutiqueMode ? Icons.storefront : Icons.person,
                        size: 20,
                      ),
                      label: _isBoutiqueMode ? 'Butik' : 'Hesabım',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

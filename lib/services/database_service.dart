import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/store.dart';
import '../models/product.dart';
import '../models/order_record.dart';

const String kMainStoreId = 'store_merkez_istasyon';
const String kBoutiquePin = '3939';
const List<String> kDistricts = ['Merkez', 'Lüleburgaz', 'Pınarhisar', 'Vize'];

/// Hibrit & Dayanıklı Veritabanı Servisi (Firestore + Reaktif Yerel Havuz)
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  bool _isFirestoreActive = false;
  bool get isFirestoreActive => _isFirestoreActive;

  // Reaktif veri kanalları
  final StreamController<List<Store>> _storesCtrl =
      StreamController<List<Store>>.broadcast();
  final StreamController<List<Product>> _productsCtrl =
      StreamController<List<Product>>.broadcast();
  final StreamController<List<OrderRecord>> _ordersCtrl =
      StreamController<List<OrderRecord>>.broadcast();

  // Bellek içi durum (Fallback & Offline)
  final List<Store> _storesCache = [];
  final List<Product> _productsCache = [];
  final List<OrderRecord> _ordersCache = [];

  StreamSubscription? _fsStoresSub;
  StreamSubscription? _fsProductsSub;
  StreamSubscription? _fsOrdersSub;

  // Varsayılan Tohum Verileri
  static final List<Store> _seedStores = [
    Store(
      id: kMainStoreId,
      name: 'İstasyon Butik',
      district: 'Merkez',
      category: 'NEW ARRIVALS / CASUAL',
      deliveryTime: '25 dk',
      rating: 4.9,
      minOrder: 200.0,
      imageUrl: 'assets/istasyon-butik-kart.png',
      phone: '0288 214 39 39',
      address: 'İstasyon Caddesi No:18, Merkez / Kırklareli',
    ),
    Store(
      id: 'store_luleburgaz_moda',
      name: 'Lüleburgaz Moda Çarşısı',
      district: 'Lüleburgaz',
      category: 'STREETWEAR & DENIM',
      deliveryTime: '30 dk',
      rating: 4.8,
      minOrder: 250.0,
      imageUrl: 'assets/luleburgaz-moda-carsisi-kart.png',
      phone: '0288 417 12 34',
      address: 'İstanbul Caddesi, Çınaraltı / Lüleburgaz',
    ),
    Store(
      id: 'store_pinarhisar_giyim',
      name: 'Pınarhisar Genç Giyim',
      district: 'Pınarhisar',
      category: 'KNITWEAR / ESSENTIALS',
      deliveryTime: '35 dk',
      rating: 4.7,
      minOrder: 150.0,
      imageUrl: 'assets/pinarhisar-genc-giyim-kart.png',
      phone: '0288 615 22 10',
      address: 'Hükümet Konağı Karşısı / Pınarhisar',
    ),
    Store(
      id: 'store_vize_butik',
      name: 'Vize Kapsül Butik',
      district: 'Vize',
      category: 'TAILORING & ACCESSORIES',
      deliveryTime: '40 dk',
      rating: 4.6,
      minOrder: 200.0,
      imageUrl: 'assets/vize-kapsul-butik-kart.png',
      phone: '0288 318 45 67',
      address: 'Kırklareli Cad. Kale Yanı / Vize',
    ),
    Store(
      id: 'store_merkez_lcw',
      name: 'LCW Kırklareli Merkez',
      district: 'Merkez',
      category: 'BASICS / DAILY',
      deliveryTime: '25 dk',
      rating: 4.7,
      minOrder: 180.0,
      imageUrl: 'assets/lcw-kirklareli-merkez-kart.png',
      phone: '0288 212 90 00',
      address: 'Fevzi Çakmak Bulvarı, Merkez / Kırklareli',
    ),
  ];

  static final List<Product> _seedProducts = [
    Product(
      id: 'k1',
      storeId: kMainStoreId,
      title: 'Kruvaze Kuşaklı Kahve Ceket',
      category: 'Dış Giyim',
      description: 'Zarif kruvaze kesim, kuşak detaylı modern kahverengi ceket.',
      price: 980.0,
      imageUrl: 'assets/ceket1.jpg',
      sizes: ['S', 'M', 'L'],
      matchWithIds: ['k2', 'k3'],
      capsuleTip: 'Her kapsül dolabın temeli: Jean veya kumaş pantolonla mükemmel uyum.',
    ),
    Product(
      id: 'k2',
      storeId: kMainStoreId,
      title: 'Çizgili Geniş Paça Kumaş Pantolon',
      category: 'Pantolon',
      description: 'Yüksek bel, dökümlü çizgili kumaş palazzo pantolon.',
      price: 649.0,
      imageUrl: 'assets/cizgilikahverengipantalon.jpg',
      sizes: ['36', '38', '40'],
      matchWithIds: ['k1', 'k4'],
      capsuleTip: 'Bacak boyunu uzun gösteren ve günlük şıklık katan temel alt parça.',
    ),
    Product(
      id: 'k3',
      storeId: kMainStoreId,
      title: 'Sivri Burun Topuklu Slingback Ayakkabı',
      category: 'Aksesuar & Ayakkabı',
      description: 'Şık ve rahat alçak topuklu rugan görünümlü ayakkabı.',
      price: 890.0,
      imageUrl: 'assets/ayakkabikahverengi.jpg',
      sizes: ['36', '37', '38', '39'],
      matchWithIds: ['k1', 'k6'],
      capsuleTip: 'Gündüzden geceye geçiş için dolapta bulunması gereken joker ayakkabı.',
    ),
    Product(
      id: 'k4',
      storeId: 'store_luleburgaz_moda',
      title: 'Drape Detaylı Deri Biker Ceket',
      category: 'Dış Giyim',
      description:
          'Premium suni deri, drape ve fermuar detaylı vintage tasarım.',
      price: 1250.0,
      imageUrl: 'assets/kahverengiceket1.jpg',
      sizes: ['S', 'M', 'L'],
      matchWithIds: ['k5', 'k8'],
      capsuleTip: 'Zamansız deri ceket: Hem spor jean hem klasik etekle kombinlenir.',
    ),
    Product(
      id: 'k5',
      storeId: 'store_luleburgaz_moda',
      title: 'Yüksek Bel Geniş Paça Mavi Jean',
      category: 'Pantolon & Denim',
      description: '%100 pamuklu denim, rahat kalıp açık mavi jean pantolon.',
      price: 580.0,
      imageUrl: 'assets/mavijean.jpg',
      sizes: ['34', '36', '38', '40'],
      matchWithIds: ['k4', 'k8'],
      capsuleTip: 'Dayanıklı pamuklu doku, mevsimsiz gardırop klasiği.',
    ),
    Product(
      id: 'k6',
      storeId: 'store_luleburgaz_moda',
      title: 'Gold Tokalı Vintage Omuz Çantası',
      category: 'Aksesuar & Ayakkabı',
      description: 'Kompakt boyutlu, gold metal toka aksesuarlı baget çanta.',
      price: 740.0,
      imageUrl: 'assets/kahverengicanta1.jpg',
      sizes: ['Standart'],
      matchWithIds: ['k4', 'k3'],
      capsuleTip: 'Tüm kahve tonlarıyla mükemmel monokrom eşleşme sağlar.',
    ),
    Product(
      id: 'k7',
      storeId: 'store_pinarhisar_giyim',
      title: 'Gold Düğmeli Kırpık Triko Hırka',
      category: 'Triko & Kazak',
      description: 'Yumuşak dokulu, crop kesim gold düğmeli gri hırka.',
      price: 520.0,
      imageUrl: 'assets/trikogrihirka.jpg',
      sizes: ['S', 'M', 'L'],
      matchWithIds: ['k5', 'k10'],
      capsuleTip: 'Gömlek üstüne veya tek başına giyilebilen çok yönlü triko.',
    ),
    Product(
      id: 'k8',
      storeId: 'store_pinarhisar_giyim',
      title: 'Bordo Balıkçı Yaka Crop Kazak',
      category: 'Triko & Kazak',
      description: 'Soğuk havalar için sıcak tutan fitilli bordo kazak.',
      price: 460.0,
      imageUrl: 'assets/kazak1.jpg',
      sizes: ['S', 'M'],
      matchWithIds: ['k5', 'k2'],
      capsuleTip: 'Sonbahar ve kış kapsül dolabının vazgeçilmez sıcak parçası.',
    ),
    Product(
      id: 'k9',
      storeId: 'store_pinarhisar_giyim',
      title: 'Fitilli Kahve Crop Bluz',
      category: 'Üst Giyim',
      description: 'Esnek pamuklu kumaş, vücudu saran kahverengi crop üst.',
      price: 340.0,
      imageUrl: 'assets/kahverengicrop.png',
      sizes: ['XS', 'S', 'M'],
      matchWithIds: ['k5'],
      capsuleTip: 'Ceket içlerine giyilebilecek en minimalist temel parça.',
    ),
    Product(
      id: 'k10',
      storeId: 'store_vize_butik',
      title: 'Kürklü Yaka Peluş Deri Ceket',
      category: 'Dış Giyim',
      description: 'İçi yünlü, kürklü geniş yaka sıcak tutan kışlık ceket.',
      price: 1390.0,
      imageUrl: 'assets/tuyluyumusakceket.jpg',
      sizes: ['S', 'M', 'L'],
      matchWithIds: ['k2', 'k11'],
      capsuleTip: 'Kırklareli soğuklarında şıklıktan ödün vermeyen ana kışlık parça.',
    ),
    Product(
      id: 'k11',
      storeId: 'store_vize_butik',
      title: 'Kare Kadran Gold Vintage Kol Saati',
      category: 'Aksesuar & Ayakkabı',
      description:
          'Zarif çelik kordon, minimalist retro kare kadranlı kol saati.',
      price: 490.0,
      imageUrl: 'assets/saat1.jpg',
      sizes: ['Standart'],
      matchWithIds: ['k12', 'k1'],
      capsuleTip: 'Zamansız aksesuar: Her görünüme anında zarafet ve kalite katar.',
    ),
    Product(
      id: 'k12',
      storeId: 'store_vize_butik',
      title: 'Gold Çiçek Formlu Mat Küpe',
      category: 'Aksesuar & Ayakkabı',
      description: 'Hafif alaşım, çiçek kabartmalı mat altın kaplama küpe.',
      price: 180.0,
      imageUrl: 'assets/goldcicekdetaylikupe.jpg',
      sizes: ['Standart'],
      matchWithIds: ['k11'],
      capsuleTip: 'Minimal dokunuş: Kombini ağırlaştırmadan parlatır.',
    ),
    Product(
      id: 'k13',
      storeId: 'store_merkez_lcw',
      title: 'İnce Askılı Çıtçıtlı Kahve Body',
      category: 'İç & Üst Giyim',
      description: 'Dikişsiz konfor sunan çıtçıtlı pamuklu temel parça.',
      price: 299.0,
      imageUrl: 'assets/kahverengi_citcitlibody.jpg',
      sizes: ['XS', 'S', 'M', 'L'],
      matchWithIds: ['k2', 'k4'],
      capsuleTip: 'Dolabın gizli kahramanı: Potluk yapmayan kusursuz astar görevi.',
    ),
  ];

  static final List<OrderRecord> _seedOrders = [
    OrderRecord(
      orderId: '#KD-892101',
      storeId: kMainStoreId,
      storeName: 'İstasyon Butik',
      totalAmount: 1629.0,
      subtotal: 1629.0,
      paymentMethod: 'Online Kredi / Banka Kartı',
      items: [
        'Kruvaze Kuşaklı Kahve Ceket [M] (x1)',
        'Çizgili Geniş Paça Kumaş Pantolon [38] (x1)',
      ],
      customerName: 'Zeynep Berra',
      customerEmail: 'zeynep@klu.edu.tr',
      address: 'Kayalı Kampüsü, Öğrenci Yurdu • Merkez',
      note: 'Yurt nizamiyesine bırakabilirsiniz.',
      tryAtDoor: false,
      status: 'Teslim Edildi',
      step: 3,
      createdAt: DateTime.now()
          .subtract(const Duration(hours: 3))
          .toIso8601String(),
    ),
  ];

  // Başlatma ve Senkronizasyon
  Future<void> initialize() async {
    // 1. Önce yerel önbelleğe tohumları doldur
    if (_storesCache.isEmpty) _storesCache.addAll(_seedStores);
    if (_productsCache.isEmpty) _productsCache.addAll(_seedProducts);
    if (_ordersCache.isEmpty) _ordersCache.addAll(_seedOrders);

    _emitStores();
    _emitProducts();
    _emitOrders();

    // 2. Firestore bağlantısını dene
    try {
      final firestore = FirebaseFirestore.instance;
      // Hafif bir okuma denemesi ile yetki ve bağlantıyı sına
      final test = await firestore
          .collection('stores')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 4));

      _isFirestoreActive = true;
      debugPrint('[DatabaseService] Cloud Firestore bağlantısı BAŞARILI.');

      // Firestore boşsa tohum verilerini yükle
      if (test.docs.isEmpty) {
        await _seedFirestore(firestore);
      }

      // Canlı Firestore dinleyicilerini başlat
      _listenFirestore(firestore);
    } catch (e) {
      _isFirestoreActive = false;
      debugPrint(
        '[DatabaseService] Firestore çevrimdışı veya sınırlı ($e). '
        'Yerel Reaktif Bellek Havuzu aktif edildi.',
      );
    }
  }

  Future<void> _seedFirestore(FirebaseFirestore fs) async {
    try {
      final batch = fs.batch();
      for (var i = 0; i < _seedStores.length; i++) {
        final s = _seedStores[i];
        batch.set(fs.collection('stores').doc(s.id), {
          ...s.toMap(),
          'order': i,
        });
      }
      for (var i = 0; i < _seedProducts.length; i++) {
        final p = _seedProducts[i];
        batch.set(fs.collection('products').doc(p.id), {
          ...p.toMap(),
          'order': i,
        });
      }
      for (final o in _seedOrders) {
        batch.set(fs.collection('orders').doc(o.orderId), o.toMap());
      }
      await batch.commit().timeout(const Duration(seconds: 6));
      debugPrint('[DatabaseService] Firestore tohum verileri başarıyla yazıldı.');
    } catch (e) {
      debugPrint('[DatabaseService] Firestore tohumlama hatası: $e');
    }
  }

  void _listenFirestore(FirebaseFirestore fs) {
    _fsStoresSub?.cancel();
    _fsStoresSub = fs.collection('stores').snapshots().listen((snap) {
      if (snap.docs.isNotEmpty) {
        final list = snap.docs
            .map((d) => Store.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        _storesCache
          ..clear()
          ..addAll(list);
        _emitStores();
      }
    }, onError: (e) => debugPrint('[DatabaseService] Butik dinleme hatası: $e'));

    _fsProductsSub?.cancel();
    _fsProductsSub = fs.collection('products').snapshots().listen((snap) {
      if (snap.docs.isNotEmpty) {
        final list = snap.docs
            .map((d) => Product.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        _productsCache
          ..clear()
          ..addAll(list);
        _emitProducts();
      }
    }, onError: (e) => debugPrint('[DatabaseService] Ürün dinleme hatası: $e'));

    _fsOrdersSub?.cancel();
    _fsOrdersSub = fs.collection('orders').snapshots().listen((snap) {
      final list = snap.docs
          .map((d) => OrderRecord.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _ordersCache
        ..clear()
        ..addAll(list);
      _emitOrders();
    }, onError: (e) => debugPrint('[DatabaseService] Sipariş dinleme hatası: $e'));
  }

  void _emitStores() {
    if (!_storesCtrl.isClosed) {
      _storesCtrl.add(List.unmodifiable(_storesCache));
    }
  }

  void _emitProducts() {
    if (!_productsCtrl.isClosed) {
      _productsCtrl.add(List.unmodifiable(_productsCache));
    }
  }

  void _emitOrders() {
    if (!_ordersCtrl.isClosed) {
      _ordersCtrl.add(List.unmodifiable(_ordersCache));
    }
  }

  // Akış API'leri
  Stream<List<Store>> watchStores() async* {
    yield List.unmodifiable(_storesCache);
    yield* _storesCtrl.stream;
  }

  Stream<List<Product>> watchProducts() async* {
    yield List.unmodifiable(_productsCache);
    yield* _productsCtrl.stream;
  }

  Stream<List<OrderRecord>> watchOrders({
    String? storeId,
    String? customerEmail,
  }) async* {
    List<OrderRecord> filter(List<OrderRecord> list) {
      return list.where((o) {
        if (storeId != null && o.storeId != storeId) return false;
        if (customerEmail != null && o.customerEmail != customerEmail) {
          return false;
        }
        return true;
      }).toList();
    }

    yield filter(_ordersCache);
    yield* _ordersCtrl.stream.map(filter);
  }

  Stream<OrderRecord?> watchOrder(String orderId) async* {
    OrderRecord? find(List<OrderRecord> list) {
      try {
        return list.firstWhere((o) => o.orderId == orderId);
      } catch (_) {
        return null;
      }
    }

    yield find(_ordersCache);
    yield* _ordersCtrl.stream.map(find);
  }

  List<Store> get currentStores => List.unmodifiable(_storesCache);
  List<Product> get currentProducts => List.unmodifiable(_productsCache);
  List<OrderRecord> get currentOrders => List.unmodifiable(_ordersCache);

  // İşlem Metodları (CRUD)
  Future<void> addProduct(Product product) async {
    // 1. Önbelleğe anında ekle
    _productsCache.insert(0, product);
    _emitProducts();

    // 2. Firestore aktifse gönder
    if (_isFirestoreActive) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(product.id)
            .set({
              ...product.toMap(),
              'order': -DateTime.now().millisecondsSinceEpoch,
            });
      } catch (e) {
        debugPrint('[DatabaseService] Firestore ürün ekleme hatası: $e');
      }
    }
  }

  Future<void> updateProductStock(String productId, bool isOutOfStock) async {
    final idx = _productsCache.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _productsCache[idx].isOutOfStock = isOutOfStock;
      _emitProducts();
    }

    if (_isFirestoreActive) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({'isOutOfStock': isOutOfStock});
      } catch (e) {
        debugPrint('[DatabaseService] Firestore stok güncelleme hatası: $e');
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    _productsCache.removeWhere((p) => p.id == productId);
    _emitProducts();

    if (_isFirestoreActive) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .delete();
      } catch (e) {
        debugPrint('[DatabaseService] Firestore ürün silme hatası: $e');
      }
    }
  }

  Future<void> registerStore(Store store) async {
    _storesCache.insert(0, store);
    _emitStores();

    if (_isFirestoreActive) {
      try {
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(store.id)
            .set(store.toMap());
      } catch (e) {
        debugPrint('[DatabaseService] Firestore butik kayıt hatası: $e');
      }
    }
  }

  Future<void> createOrder(OrderRecord order) async {
    _ordersCache.insert(0, order);
    _emitOrders();

    if (_isFirestoreActive) {
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(order.orderId)
            .set(order.toMap());
      } catch (e) {
        debugPrint('[DatabaseService] Firestore sipariş ekleme hatası: $e');
      }
    }
  }

  Future<void> updateOrderStep(String orderId, int step) async {
    final idx = _ordersCache.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      _ordersCache[idx].step = step;
      _ordersCache[idx].status = kOrderStatuses[step.clamp(0, 3)];
      _emitOrders();
    }

    if (_isFirestoreActive) {
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({
              'step': step,
              'status': kOrderStatuses[step.clamp(0, 3)],
            });
      } catch (e) {
        debugPrint('[DatabaseService] Firestore sipariş adım hatası: $e');
      }
    }
  }

  void dispose() {
    _fsStoresSub?.cancel();
    _fsProductsSub?.cancel();
    _fsOrdersSub?.cancel();
    _storesCtrl.close();
    _productsCtrl.close();
    _ordersCtrl.close();
  }
}

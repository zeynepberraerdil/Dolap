import 'package:flutter_test/flutter_test.dart';
import 'package:kapsul_dolap/models/store.dart';
import 'package:kapsul_dolap/models/product.dart';
import 'package:kapsul_dolap/models/order_record.dart';
import 'package:kapsul_dolap/services/database_service.dart';

void main() {
  group('Model ve Veritabanı Testleri', () {
    test('Store modeli toMap ve fromMap doğrulaması', () {
      final store = Store(
        id: 'test_store',
        name: 'Test Butik',
        district: 'Merkez',
        category: 'CASUAL',
        deliveryTime: '20 dk',
        rating: 4.8,
        minOrder: 150.0,
        imageUrl: 'assets/istasyon-butik-kart.png',
      );

      final map = store.toMap();
      expect(map['name'], 'Test Butik');
      expect(map['district'], 'Merkez');

      final fromMapStore = Store.fromMap('test_store', map);
      expect(fromMapStore.id, 'test_store');
      expect(fromMapStore.rating, 4.8);
    });

    test('Product modeli stok durumu ve kapsül tavsiyesi testi', () {
      final product = Product(
        id: 'test_p1',
        storeId: 'test_store',
        title: 'Özel Kruvaze Ceket',
        category: 'Dış Giyim',
        price: 750.0,
        imageUrl: 'assets/ceket1.jpg',
        sizes: ['S', 'M'],
        capsuleTip: 'Temel ceket kombini',
      );

      expect(product.isOutOfStock, false);
      product.isOutOfStock = true;
      expect(product.isOutOfStock, true);
      expect(product.capsuleTip, 'Temel ceket kombini');
    });

    test('OrderRecord modeli kurye ve adım ilerleme testi', () {
      final order = OrderRecord(
        orderId: '#KD-999',
        storeId: 'store_merkez_istasyon',
        storeName: 'İstasyon Butik',
        totalAmount: 950.0,
        subtotal: 950.0,
        paymentMethod: 'Online Kart',
        items: ['Kruvaze Ceket [M] (x1)'],
        customerName: 'Zeynep Berra',
        customerEmail: 'zeynep@klu.edu.tr',
        address: 'Kayalı Kampüsü',
        step: 0,
      );

      expect(order.step, 0);
      expect(order.status, 'Hazırlanıyor (Butik Onayı Bekleniyor)');
    });

    test('DatabaseService reaktif ekleme ve güncelleme testi', () async {
      final db = DatabaseService();
      await db.initialize();

      final initialCount = db.currentProducts.length;

      final testProduct = Product(
        id: 'test_p_unique_${DateTime.now().millisecondsSinceEpoch}',
        storeId: kMainStoreId,
        title: 'Birim Test Ürünü',
        category: 'Test',
        price: 199.0,
        imageUrl: 'assets/ceket1.jpg',
        sizes: ['Standart'],
      );

      await db.addProduct(testProduct);
      expect(db.currentProducts.length, initialCount + 1);

      // Stok güncelleme
      await db.updateProductStock(testProduct.id, true);
      final updated = db.currentProducts.firstWhere((p) => p.id == testProduct.id);
      expect(updated.isOutOfStock, true);

      // Ürün silme
      await db.deleteProduct(testProduct.id);
      expect(db.currentProducts.any((p) => p.id == testProduct.id), false);
    });
  });
}

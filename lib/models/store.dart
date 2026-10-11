class Store {
  final String id;
  final String name;
  final String district;
  final String category;
  final String deliveryTime;
  final double rating;
  final double minOrder;
  final String imageUrl;
  final int order;
  final String phone;
  final String address;

  Store({
    required this.id,
    required this.name,
    required this.district,
    required this.category,
    required this.deliveryTime,
    required this.rating,
    required this.minOrder,
    required this.imageUrl,
    this.order = 0,
    this.phone = '0288 214 00 39',
    this.address = 'İstasyon Caddesi No:18, Merkez / Kırklareli',
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'district': district,
    'category': category,
    'deliveryTime': deliveryTime,
    'rating': rating,
    'minOrder': minOrder,
    'imageUrl': imageUrl,
    'order': order,
    'phone': phone,
    'address': address,
  };

  factory Store.fromMap(String docId, Map<String, dynamic> map) {
    return Store(
      id: docId,
      name: map['name'] ?? '',
      district: map['district'] ?? '',
      category: map['category'] ?? '',
      deliveryTime: map['deliveryTime'] ?? '30 dk',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      minOrder: (map['minOrder'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? 'assets/istasyon-butik-kart.png',
      order: (map['order'] as num?)?.toInt() ?? 0,
      phone: map['phone'] ?? '0288 214 00 39',
      address: map['address'] ?? 'İstasyon Caddesi, Kırklareli',
    );
  }
}

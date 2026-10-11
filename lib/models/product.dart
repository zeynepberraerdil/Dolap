class Product {
  final String id;
  final String storeId;
  final String title;
  final String category;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final List<String> matchWithIds;
  final int order;
  bool isOutOfStock;
  final String capsuleTip;

  Product({
    required this.id,
    required this.storeId,
    required this.title,
    required this.category,
    this.description = 'Kırklareli yerel butik koleksiyonundan seçkin parça.',
    required this.price,
    required this.imageUrl,
    required this.sizes,
    this.matchWithIds = const [],
    this.isOutOfStock = false,
    this.order = 0,
    this.capsuleTip = 'Temel kapsül parça: Hem ofis hem günlük kombine uyar.',
  });

  Map<String, dynamic> toMap() => {
    'storeId': storeId,
    'title': title,
    'category': category,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'sizes': sizes,
    'matchWithIds': matchWithIds,
    'isOutOfStock': isOutOfStock,
    'order': order,
    'capsuleTip': capsuleTip,
  };

  factory Product.fromMap(String docId, Map<String, dynamic> map) {
    final sizes = List<String>.from(map['sizes'] ?? []);
    return Product(
      id: docId,
      storeId: map['storeId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? 'Kırklareli yerel butik parçası.',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? 'assets/ceket1.jpg',
      sizes: sizes.isEmpty ? ['Standart'] : sizes,
      matchWithIds: List<String>.from(map['matchWithIds'] ?? []),
      isOutOfStock: map['isOutOfStock'] ?? false,
      order: (map['order'] as num?)?.toInt() ?? 0,
      capsuleTip: map['capsuleTip'] ?? 'Temel kapsül gardırop parçası.',
    );
  }
}

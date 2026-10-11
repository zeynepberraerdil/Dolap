class CartItem {
  final String title;
  final String storeId;
  final String storeName;
  final String size;
  final double price;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.title,
    required this.storeId,
    required this.storeName,
    required this.size,
    required this.price,
    this.quantity = 1,
    this.imageUrl = 'assets/ceket1.jpg',
  });
}

const List<String> kOrderStatuses = [
  'Hazırlanıyor (Butik Onayı Bekleniyor)',
  'Kurye Yolda',
  'Teslimat Yolunda',
  'Teslim Edildi',
];

class OrderRecord {
  final String orderId;
  final String storeId;
  final String storeName;
  final double totalAmount;
  final double subtotal;
  final double discountAmount;
  final String couponCode;
  final String paymentMethod;
  final List<String> items;
  final String customerName;
  final String customerEmail;
  final String address;
  final String note;
  final bool tryAtDoor;
  final String createdAt;
  final String courierName;
  final String courierPlate;
  String status;
  int step;

  OrderRecord({
    required this.orderId,
    required this.storeId,
    required this.storeName,
    required this.totalAmount,
    this.subtotal = 0.0,
    this.discountAmount = 0.0,
    this.couponCode = '',
    required this.paymentMethod,
    required this.items,
    this.customerName = '',
    this.customerEmail = '',
    this.address = '',
    this.note = '',
    this.tryAtDoor = false,
    String? createdAt,
    this.courierName = 'Ahmet K.',
    this.courierPlate = '39 AB 123 (Honda PCX)',
    this.status = 'Hazırlanıyor (Butik Onayı Bekleniyor)',
    this.step = 0,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'storeId': storeId,
    'storeName': storeName,
    'totalAmount': totalAmount,
    'subtotal': subtotal,
    'discountAmount': discountAmount,
    'couponCode': couponCode,
    'paymentMethod': paymentMethod,
    'items': items,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'address': address,
    'note': note,
    'tryAtDoor': tryAtDoor,
    'courierName': courierName,
    'courierPlate': courierPlate,
    'status': status,
    'step': step,
    'createdAt': createdAt,
  };

  factory OrderRecord.fromMap(String docId, Map<String, dynamic> map) {
    return OrderRecord(
      orderId: docId,
      storeId: map['storeId'] ?? '',
      storeName: map['storeName'] ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      couponCode: map['couponCode'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Online Kart',
      items: List<String>.from(map['items'] ?? []),
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      address: map['address'] ?? '',
      note: map['note'] ?? '',
      tryAtDoor: map['tryAtDoor'] ?? false,
      courierName: map['courierName'] ?? 'Ahmet K.',
      courierPlate: map['courierPlate'] ?? '39 AB 123 (Honda PCX)',
      createdAt: map['createdAt'] ?? '',
      status: map['status'] ?? kOrderStatuses[0],
      step: (map['step'] as num?)?.toInt() ?? 0,
    );
  }

  String get dateLabel {
    final d = DateTime.tryParse(createdAt)?.toLocal();
    if (d == null) return '';
    String t(int n) => n.toString().padLeft(2, '0');
    return '${t(d.day)}.${t(d.month)} ${t(d.hour)}:${t(d.minute)}';
  }

  bool get isToday {
    final d = DateTime.tryParse(createdAt)?.toLocal();
    final now = DateTime.now();
    return d != null &&
        d.year == now.year &&
        d.month == now.month &&
        d.day == now.day;
  }
}

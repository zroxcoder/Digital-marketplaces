class OrderModel {
  final String id;
  final String productId;
  final String productTitle;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final double price;
  final DateTime purchaseDate;
  final String fileUrl;

  OrderModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.price,
    required this.purchaseDate,
    required this.fileUrl,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      productId: map['productId'] ?? '',
      productTitle: map['productTitle'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      purchaseDate: DateTime.parse(map['purchaseDate']),
      fileUrl: map['fileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'fileUrl': fileUrl,
    };
  }
}
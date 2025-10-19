class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String sellerId;
  final String sellerName;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final List<String> tags;
  final int downloadCount;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerId,
    required this.sellerName,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.thumbnailUrl,
    required this.createdAt,
    this.tags = const [],
    this.downloadCount = 0,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      fileType: map['fileType'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      thumbnailUrl: map['thumbnailUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      tags: List<String>.from(map['tags'] ?? []),
      downloadCount: map['downloadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'downloadCount': downloadCount,
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
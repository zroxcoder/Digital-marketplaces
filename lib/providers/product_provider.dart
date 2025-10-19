import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> createProduct({
    required String title,
    required String description,
    required double price,
    required String sellerId,
    required String sellerName,
    required File file,
    required String fileName,
    required String fileType,
    required int fileSize,
    List<String> tags = const [],
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload file
      String fileUrl = await _storageService.uploadFile(file, sellerId);

      // Create product
      ProductModel product = ProductModel(
        id: '',
        title: title,
        description: description,
        price: price,
        sellerId: sellerId,
        sellerName: sellerName,
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
        createdAt: DateTime.now(),
        tags: tags,
      );

      await _firebaseService.createProduct(product);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseService.updateProduct(productId, data);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId, String sellerId, String fileUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Delete file from storage
      await _storageService.deleteFile(fileUrl);

      // Delete product from Firestore
      await _firebaseService.deleteProduct(productId, sellerId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Stream<List<ProductModel>> getAllProducts() {
    return _firebaseService.getAllProducts();
  }

  Stream<List<ProductModel>> getUserProducts(String userId) {
    return _firebaseService.getUserProducts(userId);
  }

  Future<ProductModel?> getProduct(String productId) async {
    return await _firebaseService.getProduct(productId);
  }

  Future<void> purchaseProduct({
    required ProductModel product,
    required String buyerId,
    required String buyerName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      OrderModel order = OrderModel(
        id: '',
        productId: product.id,
        productTitle: product.title,
        buyerId: buyerId,
        buyerName: buyerName,
        sellerId: product.sellerId,
        sellerName: product.sellerName,
        price: product.price,
        purchaseDate: DateTime.now(),
        fileUrl: product.fileUrl,
      );

      await _firebaseService.createOrder(order);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Stream<List<OrderModel>> getUserPurchases(String userId) {
    return _firebaseService.getUserPurchases(userId);
  }

  Stream<List<OrderModel>> getUserSales(String userId) {
    return _firebaseService.getUserSales(userId);
  }

  Future<bool> hasUserPurchased(String userId, String productId) async {
    return await _firebaseService.hasUserPurchased(userId, productId);
  }
}
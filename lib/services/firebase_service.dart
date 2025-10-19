import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/message_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth Methods
  Future<User?> signUp(String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        
        UserModel userModel = UserModel(
          id: user.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      }

      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // User Methods
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Product Methods
  Future<String> createProduct(ProductModel product) async {
    try {
      DocumentReference ref = await _firestore.collection('products').add(product.toMap());
      
      // Update user's product list
      await _firestore.collection('users').doc(product.sellerId).update({
        'productIds': FieldValue.arrayUnion([ref.id])
      });

      return ref.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(productId).update(data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId, String sellerId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      
      await _firestore.collection('users').doc(sellerId).update({
        'productIds': FieldValue.arrayRemove([productId])
      });
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Stream<List<ProductModel>> getAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<ProductModel>> getUserProducts(String userId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // Order Methods
  Future<String> createOrder(OrderModel order) async {
    try {
      DocumentReference ref = await _firestore.collection('orders').add(order.toMap());
      
      // Update buyer's purchase list
      await _firestore.collection('users').doc(order.buyerId).update({
        'purchaseIds': FieldValue.arrayUnion([ref.id])
      });

      // Increment download count
      await _firestore.collection('products').doc(order.productId).update({
        'downloadCount': FieldValue.increment(1)
      });

      return ref.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Stream<List<OrderModel>> getUserPurchases(String userId) {
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<OrderModel>> getUserSales(String userId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<bool> hasUserPurchased(String userId, String productId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Chat Methods
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore.collection('messages').add(message.toMap());
      
      // Update or create chat metadata
      await _firestore.collection('chats').doc(message.chatId).set({
        'participants': [message.senderId, message.receiverId],
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastSenderId': message.senderId,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> chats = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> chatData = doc.data();
        chatData['id'] = doc.id;
        
        // Get other user's info
        List<String> participants = List<String>.from(chatData['participants']);
        String otherUserId = participants.firstWhere((id) => id != userId);
        
        UserModel? otherUser = await getUserData(otherUserId);
        chatData['otherUser'] = otherUser;
        
        chats.add(chatData);
      }
      
      return chats;
    });
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      QuerySnapshot unreadMessages = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }
}
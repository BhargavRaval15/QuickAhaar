import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_ahaar/models/cart_item.dart';
import 'package:quick_ahaar/models/order.dart' as app_order;
import 'package:uuid/uuid.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';
  final Uuid _uuid = const Uuid();

  Future<app_order.Order> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
  }) async {
    try {
      print('OrderService: Starting order creation');
      print('OrderService: User ID: $userId');
      print('OrderService: Items count: ${items.length}');
      print('OrderService: Items details: ${items.map((item) => '${item.name} (${item.quantity}x)').join(', ')}');
      print('OrderService: Total amount: $totalAmount');

      final orderId = _firestore.collection(_collection).doc().id;
      final token = _uuid.v4().substring(0, 8).toUpperCase();
      print('OrderService: Generated order ID: $orderId');
      print('OrderService: Generated token: $token');

      final order = app_order.Order(
        id: orderId,
        token: token,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        status: app_order.OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('OrderService: Order object created');
      print('OrderService: Order data to save: ${order.toMap()}');

      // Save to Firestore
      await _firestore.collection(_collection).doc(orderId).set(order.toMap());
      print('OrderService: Order saved to Firestore successfully');

      // Verify the order exists in Firestore
      final verificationDoc = await _firestore.collection(_collection).doc(orderId).get();
      print('OrderService: Order verification - exists: ${verificationDoc.exists}');
      if (verificationDoc.exists) {
        print('OrderService: Order data in Firestore: ${verificationDoc.data()}');
      } else {
        print('OrderService: WARNING - Order not found in Firestore after saving!');
      }

      return order;
    } catch (e, stackTrace) {
      print('OrderService: Error placing order:');
      print('OrderService: Error message: $e');
      print('OrderService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<app_order.Order>> getUserOrders(String userId) async {
    print('Fetching orders for user: $userId');
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('Received ${snapshot.docs.length} orders from Firestore');
      print('Order documents: ${snapshot.docs.map((doc) => doc.data()).toList()}');
      return snapshot.docs
          .map((doc) => app_order.Order.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      rethrow;
    }
  }

  Future<List<app_order.Order>> getAllOrders() async {
    print('OrderService: Starting to fetch all orders');
    try {
      print('OrderService: Querying Firestore for orders');
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      print('OrderService: Received ${snapshot.docs.length} orders from Firestore');
      
      if (snapshot.docs.isEmpty) {
        print('OrderService: No orders found in Firestore');
        return [];
      }

      print('OrderService: Processing order documents');
      final orders = snapshot.docs.map((doc) {
        print('OrderService: Processing document ID: ${doc.id}');
        final data = doc.data();
        print('OrderService: Document data: $data');
        
        try {
          final order = app_order.Order.fromMap({...data, 'id': doc.id});
          print('OrderService: Successfully created order object: ${order.token}');
          return order;
        } catch (e) {
          print('OrderService: Error processing document ${doc.id}:');
          print('OrderService: Error message: $e');
          print('OrderService: Document data: $data');
          rethrow;
        }
      }).toList();

      print('OrderService: Successfully processed ${orders.length} orders');
      return orders;
    } catch (e, stackTrace) {
      print('OrderService: Error fetching all orders:');
      print('OrderService: Error message: $e');
      print('OrderService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, app_order.OrderStatus status) async {
    try {
      print('Updating order status in Firestore: $orderId to $status');
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Order status updated successfully');
    } catch (e) {
      print('Error updating order status in Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateOrder(app_order.Order order) async {
    try {
      print('Updating order in Firestore: ${order.id}');
      await _firestore.collection(_collection).doc(order.id).update({
        'rating': order.rating,
        'feedback': order.feedback,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Order updated successfully');
    } catch (e) {
      print('Error updating order in Firestore: $e');
      rethrow;
    }
  }

  Future<app_order.Order> getOrderByToken(String token) async {
    try {
      print('Fetching order by token: $token');
      final snapshot = await _firestore
          .collection(_collection)
          .where('token', isEqualTo: token)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No order found with token: $token');
        throw Exception('Order not found');
      }

      print('Found order: ${snapshot.docs.first.data()}');
      final doc = snapshot.docs.first;
      return app_order.Order.fromMap({...doc.data(), 'id': doc.id});
    } catch (e) {
      print('Error fetching order by token: $e');
      throw Exception('Failed to fetch order: $e');
    }
  }
} 
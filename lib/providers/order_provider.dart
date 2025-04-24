import 'package:flutter/foundation.dart';
import 'package:quick_ahaar/models/cart_item.dart';
import 'package:quick_ahaar/models/order.dart' as app_order;
import 'package:quick_ahaar/services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<app_order.Order> _orders = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<app_order.Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<app_order.Order> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('OrderProvider: Starting order placement');
      print('OrderProvider: User ID: $userId');
      print('OrderProvider: Number of items: ${items.length}');
      print('OrderProvider: Items details: ${items.map((item) => '${item.name}: ${item.quantity}x').join(', ')}');
      print('OrderProvider: Total amount: $totalAmount');
      
      final order = await _orderService.placeOrder(
        userId: userId,
        items: items,
        totalAmount: totalAmount,
      );
      
      print('OrderProvider: Order placed successfully');
      print('OrderProvider: Order ID: ${order.id}');
      print('OrderProvider: Order token: ${order.token}');
      print('OrderProvider: Order status: ${order.status}');
      print('OrderProvider: Order created at: ${order.createdAt}');
      
      // Verify the order exists in Firestore immediately after creation
      final verificationDoc = await FirebaseFirestore.instance.collection('orders').doc(order.id).get();
      print('OrderProvider: Order verification - exists in Firestore: ${verificationDoc.exists}');
      if (verificationDoc.exists) {
        print('OrderProvider: Order data in Firestore: ${verificationDoc.data()}');
      }
      
      _orders.insert(0, order);
      return order;
    } catch (e, stackTrace) {
      print('OrderProvider: Error placing order:');
      print('OrderProvider: Error message: $e');
      print('OrderProvider: Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserOrders(String userId) async {
    print('Loading orders for user: $userId');
    try {
      final orders = await _orderService.getUserOrders(userId);
      print('Received ${orders.length} orders');
      _orders = orders;
      notifyListeners();
    } catch (error) {
      print('Error loading orders: $error');
    }
  }

  Future<void> loadAllOrders() async {
    print('Loading all orders');
    try {
      _isLoading = true;
      notifyListeners();

      final orders = await _orderService.getAllOrders();
      print('Received ${orders.length} orders');
      _orders = orders;
      notifyListeners();
    } catch (error) {
      print('Error loading all orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, app_order.OrderStatus newStatus) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _orderService.updateOrderStatus(orderId, newStatus);
      
      // Update the order in the local list
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmOrder(String orderId) async {
    await updateOrderStatus(orderId, app_order.OrderStatus.processing);
  }

  Future<void> markOrderAsPreparing(String orderId) async {
    await updateOrderStatus(orderId, app_order.OrderStatus.dispatched);
  }

  Future<void> markOrderAsOutForDelivery(String orderId) async {
    await updateOrderStatus(orderId, app_order.OrderStatus.delivered);
  }

  Future<void> markOrderAsDelivered(String orderId) async {
    await updateOrderStatus(orderId, app_order.OrderStatus.delivered);
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, app_order.OrderStatus.cancelled);
  }

  Future<void> updateOrder(app_order.Order updatedOrder) async {
    try {
      print('Updating order: ${updatedOrder.id}');
      await _orderService.updateOrder(updatedOrder);
      final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  app_order.Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<app_order.Order> getOrdersByStatus(app_order.OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  Future<app_order.Order> getOrderByToken(String token) async {
    try {
      return await _orderService.getOrderByToken(token);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }
} 
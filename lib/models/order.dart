import 'package:quick_ahaar/models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  processing,
  dispatched,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String token;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final String? feedback;
  final bool canCancel;

  Order({
    required this.id,
    required this.token,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.feedback,
    this.canCancel = true,
  });

  Order copyWith({
    String? id,
    String? token,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    String? feedback,
    bool? canCancel,
  }) {
    return Order(
      id: id ?? this.id,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      canCancel: canCancel ?? this.canCancel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'rating': rating,
      'feedback': feedback,
      'canCancel': canCancel,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      token: map['token'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: map['rating']?.toDouble(),
      feedback: map['feedback'],
      canCancel: map['canCancel'] ?? true,
    );
  }

  bool get isCancellable => canCancel && (status == OrderStatus.pending || status == OrderStatus.processing);
  bool get canRate => status == OrderStatus.delivered && rating == null;
} 
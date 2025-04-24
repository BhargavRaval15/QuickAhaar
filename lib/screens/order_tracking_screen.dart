import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ahaar/providers/order_provider.dart';
import 'package:quick_ahaar/models/order.dart' as app_order;
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatefulWidget {
  final app_order.Order? initialOrder;

  const OrderTrackingScreen({super.key, this.initialOrder});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  app_order.Order? _trackedOrder;

  @override
  void initState() {
    super.initState();
    _trackedOrder = widget.initialOrder;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _trackedOrder = null;
    });

    try {
      final order = await context.read<OrderProvider>().getOrderByToken(_tokenController.text);
      setState(() {
        _trackedOrder = order;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error tracking order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStatusIcon(app_order.OrderStatus status) {
    switch (status) {
      case app_order.OrderStatus.pending:
        return '⏳';
      case app_order.OrderStatus.processing:
        return '👨‍🍳';
      case app_order.OrderStatus.dispatched:
        return '🚚';
      case app_order.OrderStatus.delivered:
        return '✅';
      case app_order.OrderStatus.cancelled:
        return '❌';
    }
  }

  String _getStatusText(app_order.OrderStatus status) {
    switch (status) {
      case app_order.OrderStatus.pending:
        return 'Order Pending';
      case app_order.OrderStatus.processing:
        return 'Preparing Your Order';
      case app_order.OrderStatus.dispatched:
        return 'On the Way';
      case app_order.OrderStatus.delivered:
        return 'Delivered';
      case app_order.OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(app_order.OrderStatus status) {
    switch (status) {
      case app_order.OrderStatus.pending:
        return Colors.orange;
      case app_order.OrderStatus.processing:
        return Colors.blue;
      case app_order.OrderStatus.dispatched:
        return Colors.purple;
      case app_order.OrderStatus.delivered:
        return Colors.green;
      case app_order.OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildStatusTimeline(app_order.Order order) {
    return Column(
      children: [
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isFirst: true,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: _getStatusColor(app_order.OrderStatus.pending),
            iconStyle: IconStyle(
              iconData: Icons.access_time,
              color: Colors.white,
            ),
          ),
          beforeLineStyle: LineStyle(
            color: order.status.index >= app_order.OrderStatus.pending.index
                ? _getStatusColor(app_order.OrderStatus.pending)
                : Colors.grey,
          ),
          afterLineStyle: LineStyle(
            color: order.status.index > app_order.OrderStatus.pending.index
                ? _getStatusColor(app_order.OrderStatus.processing)
                : Colors.grey,
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Placed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: order.status.index >= app_order.OrderStatus.pending.index
                        ? _getStatusColor(app_order.OrderStatus.pending)
                        : Colors.grey,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: _getStatusColor(app_order.OrderStatus.processing),
            iconStyle: IconStyle(
              iconData: Icons.restaurant,
              color: Colors.white,
            ),
          ),
          beforeLineStyle: LineStyle(
            color: order.status.index >= app_order.OrderStatus.processing.index
                ? _getStatusColor(app_order.OrderStatus.processing)
                : Colors.grey,
          ),
          afterLineStyle: LineStyle(
            color: order.status.index > app_order.OrderStatus.processing.index
                ? _getStatusColor(app_order.OrderStatus.dispatched)
                : Colors.grey,
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preparing',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: order.status.index >= app_order.OrderStatus.processing.index
                        ? _getStatusColor(app_order.OrderStatus.processing)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: _getStatusColor(app_order.OrderStatus.dispatched),
            iconStyle: IconStyle(
              iconData: Icons.delivery_dining,
              color: Colors.white,
            ),
          ),
          beforeLineStyle: LineStyle(
            color: order.status.index >= app_order.OrderStatus.dispatched.index
                ? _getStatusColor(app_order.OrderStatus.dispatched)
                : Colors.grey,
          ),
          afterLineStyle: LineStyle(
            color: order.status.index > app_order.OrderStatus.dispatched.index
                ? _getStatusColor(app_order.OrderStatus.delivered)
                : Colors.grey,
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Out for Delivery',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: order.status.index >= app_order.OrderStatus.dispatched.index
                        ? _getStatusColor(app_order.OrderStatus.dispatched)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isLast: true,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: _getStatusColor(app_order.OrderStatus.delivered),
            iconStyle: IconStyle(
              iconData: Icons.check_circle,
              color: Colors.white,
            ),
          ),
          beforeLineStyle: LineStyle(
            color: order.status.index >= app_order.OrderStatus.delivered.index
                ? _getStatusColor(app_order.OrderStatus.delivered)
                : Colors.grey,
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivered',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: order.status.index >= app_order.OrderStatus.delivered.index
                        ? _getStatusColor(app_order.OrderStatus.delivered)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_trackedOrder == null) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _tokenController,
                            decoration: const InputDecoration(
                              labelText: 'Order Token',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your order token';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _trackOrder,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Track Order'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (_trackedOrder != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${_trackedOrder!.token}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _trackOrder,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatusTimeline(_trackedOrder!),
                        const SizedBox(height: 16),
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._trackedOrder!.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.name),
                                  Text('x${item.quantity}'),
                                ],
                              ),
                            )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_trackedOrder!.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (_trackedOrder!.status == app_order.OrderStatus.pending) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await context.read<OrderProvider>().confirmOrder(_trackedOrder!.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Order confirmed successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _trackOrder(); // Refresh the order status
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error confirming order: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Confirm Order'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 
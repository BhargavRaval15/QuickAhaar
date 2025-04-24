import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ahaar/providers/auth_provider.dart';
import 'package:quick_ahaar/providers/order_provider.dart';
import 'package:quick_ahaar/models/order.dart' as app_order;
import 'package:quick_ahaar/screens/order_tracking_screen.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_ahaar/screens/admin_operating_hours_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    print('AdminDashboardScreen: Initializing');
    Future.microtask(() async {
      print('AdminDashboardScreen: Loading all orders');
      try {
        // First verify that we can access Firestore
        final firestore = FirebaseFirestore.instance;
        print('AdminDashboardScreen: Checking Firestore access');
        
        // Try to list documents in the orders collection
        final querySnapshot = await firestore.collection('orders').get();
        print('AdminDashboardScreen: Direct Firestore query - Found ${querySnapshot.docs.length} orders');
        for (var doc in querySnapshot.docs) {
          print('AdminDashboardScreen: Order document - ID: ${doc.id}');
          print('AdminDashboardScreen: Order data: ${doc.data()}');
        }
        
        // Now load orders through the provider
        await context.read<OrderProvider>().loadAllOrders();
        print('AdminDashboardScreen: Orders loaded through provider');
        
        // Verify orders in provider
        final orderProvider = context.read<OrderProvider>();
        print('AdminDashboardScreen: Provider has ${orderProvider.orders.length} orders');
        for (var order in orderProvider.orders) {
          print('AdminDashboardScreen: Order in provider - ID: ${order.id}, Token: ${order.token}, Status: ${order.status}');
        }
      } catch (error, stackTrace) {
        print('AdminDashboardScreen: Error loading orders:');
        print('AdminDashboardScreen: Error message: $error');
        print('AdminDashboardScreen: Stack trace: $stackTrace');
      }
    });
  }

  Future<void> _updateOrderStatus(BuildContext context, app_order.Order order) async {
    final newStatus = await showDialog<app_order.OrderStatus>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pending'),
              onTap: () => Navigator.pop(context, app_order.OrderStatus.pending),
            ),
            ListTile(
              title: const Text('Processing'),
              onTap: () => Navigator.pop(context, app_order.OrderStatus.processing),
            ),
            ListTile(
              title: const Text('Dispatched'),
              onTap: () => Navigator.pop(context, app_order.OrderStatus.dispatched),
            ),
            ListTile(
              title: const Text('Delivered'),
              onTap: () => Navigator.pop(context, app_order.OrderStatus.delivered),
            ),
            ListTile(
              title: const Text('Cancelled'),
              onTap: () => Navigator.pop(context, app_order.OrderStatus.cancelled),
            ),
          ],
        ),
      ),
    );

    if (newStatus != null) {
      try {
        await context.read<OrderProvider>().updateOrderStatus(order.id, newStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order status updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating status: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AdminDashboardScreen: Building widget');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              print('AdminDashboardScreen: Manual refresh triggered');
              try {
                await context.read<OrderProvider>().loadAllOrders();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Orders refreshed')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error refreshing orders: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminOperatingHoursScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/admin-login');
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          print('AdminDashboardScreen: Consumer builder called');
          print('AdminDashboardScreen: isLoading: ${orderProvider.isLoading}');
          print('AdminDashboardScreen: orders count: ${orderProvider.orders.length}');

          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.orders.isEmpty) {
            print('AdminDashboardScreen: No orders found');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No orders found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      print('AdminDashboardScreen: Retry loading orders');
                      await context.read<OrderProvider>().loadAllOrders();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              print('AdminDashboardScreen: Pull to refresh triggered');
              await context.read<OrderProvider>().loadAllOrders();
            },
            child: ListView.builder(
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                print('AdminDashboardScreen: Building order card for order ${order.token}');
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text('Order #${order.token}'),
                    subtitle: Text(
                      'Status: ${order.status.toString().split('.').last}',
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(order.userId)
                                  .get(),
                              builder: (context, snapshot) {
                                print('AdminDashboardScreen: Fetching user data for order ${order.token}');
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                                print('AdminDashboardScreen: User data: $userData');
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer: ${userData?['name'] ?? 'Unknown'}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Email: ${userData?['email'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text('Phone: ${userData?['phone'] ?? 'N/A'}'),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.email, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            userData?['email'] ?? 'N/A',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Order Items:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${item.name} (x${item.quantity})'),
                                      Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                                    ],
                                  ),
                                )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '\$${order.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Order Date: ${DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _updateOrderStatus(context, order),
                                  child: const Text('Update Status'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderTrackingScreen(initialOrder: order),
                                      ),
                                    );
                                  },
                                  child: const Text('Track Order'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
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
} 
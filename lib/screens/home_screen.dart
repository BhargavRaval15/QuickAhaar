import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ahaar/providers/auth_provider.dart';
import 'package:quick_ahaar/providers/cart_provider.dart';
import 'package:quick_ahaar/providers/category_provider.dart';
import 'package:quick_ahaar/models/cart_item.dart';
import 'package:quick_ahaar/screens/cart_screen.dart';
import 'package:quick_ahaar/screens/categories_screen.dart';
import 'package:quick_ahaar/screens/orders_screen.dart';
import 'package:quick_ahaar/screens/profile_screen.dart';
import 'package:quick_ahaar/screens/order_history_screen.dart';
import 'package:quick_ahaar/theme/app_theme.dart';
import 'package:quick_ahaar/widgets/food_category_card.dart';
import 'package:quick_ahaar/widgets/food_item_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _selectedIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> foodItems = [
    {
      'name': 'Butter Chicken',
      'price': 299.0,
      'imageUrl': 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143',
      'category': 'Indian',
      'description': 'Tender chicken in rich tomato and butter sauce',
      'isVeg': false,
    },
    {
      'name': 'Paneer Tikka',
      'price': 249.0,
      'imageUrl': 'https://images.unsplash.com/photo-1601050690597-df0568f70950',
      'category': 'Indian',
      'description': 'Grilled cottage cheese with spices',
      'isVeg': true,
    },
    {
      'name': 'Margherita Pizza',
      'price': 399.0,
      'imageUrl': 'https://images.unsplash.com/photo-1590947132387-155cc02f3212',
      'category': 'Italian',
      'description': 'Classic pizza with tomato sauce and mozzarella',
      'isVeg': true,
    },
    {
      'name': 'Kung Pao Chicken',
      'price': 349.0,
      'imageUrl': 'https://images.unsplash.com/photo-1563245372-f21724e3856d',
      'category': 'Chinese',
      'description': 'Spicy stir-fried chicken with peanuts',
      'isVeg': false,
    },
    {
      'name': 'Vegetable Fried Rice',
      'price': 199.0,
      'imageUrl': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b',
      'category': 'Chinese',
      'description': 'Stir-fried rice with fresh vegetables',
      'isVeg': true,
    },
    {
      'name': 'Chicken Burger',
      'price': 199.0,
      'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
      'category': 'Fast Food',
      'description': 'Juicy chicken patty with fresh vegetables',
      'isVeg': false,
    },
    {
      'name': 'Veg Burger',
      'price': 179.0,
      'imageUrl': 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9',
      'category': 'Fast Food',
      'description': 'Crispy veg patty with fresh vegetables',
      'isVeg': true,
    },
    {
      'name': 'Tiramisu',
      'price': 249.0,
      'imageUrl': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9',
      'category': 'Desserts',
      'description': 'Classic Italian coffee-flavored dessert',
      'isVeg': true,
    },
    {
      'name': 'Biryani',
      'price': 349.0,
      'imageUrl': 'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a',
      'category': 'Indian',
      'description': 'Fragrant rice dish with spices and meat',
      'isVeg': false,
    },
    {
      'name': 'Veg Biryani',
      'price': 299.0,
      'imageUrl': 'https://images.unsplash.com/photo-1589302168068-964664d93dc0',
      'category': 'Indian',
      'description': 'Fragrant rice dish with mixed vegetables',
      'isVeg': true,
    },
    {
      'name': 'Chocolate Brownie',
      'price': 149.0,
      'imageUrl': 'https://images.unsplash.com/photo-1564355808539-22fda35bed7e',
      'category': 'Desserts',
      'description': 'Rich chocolate brownie with nuts',
      'isVeg': true,
    },
    {
      'name': 'Pasta Alfredo',
      'price': 279.0,
      'imageUrl': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141',
      'category': 'Italian',
      'description': 'Creamy pasta with parmesan cheese',
      'isVeg': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  List<Map<String, dynamic>> get _filteredItems {
    return foodItems.where((item) {
      final nameMatch = item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final categoryMatch = item['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final descriptionMatch = item['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || categoryMatch || descriptionMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cartProvider = context.watch<CartProvider>();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: const Text(
                              'Welcome!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.person),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for food...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _selectedIndex == 0
                          ? _buildFoodItems()
                          : _buildSelectedScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              elevation: 0,
            ),
          ),
        ),
      ),
      floatingActionButton: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.accentColor,
                child: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartProvider.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            cartProvider.itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItems() {
    final filteredItems = _filteredItems;
    
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return FoodItemCard(
          name: item['name'],
          price: item['price'],
          imageUrl: item['imageUrl'],
          description: item['description'],
          isVeg: item['isVeg'],
          onAddToCart: () {
            final cartProvider = Provider.of<CartProvider>(context, listen: false);
            cartProvider.addItem(
              CartItem(
                id: '${item['name']}_${DateTime.now().millisecondsSinceEpoch}',
                name: item['name'],
                price: item['price'],
                quantity: 1,
                imageUrl: item['imageUrl'],
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item['name']} added to cart'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildFoodItems();
      case 1:
        return const OrderHistoryScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _buildFoodItems();
    }
  }
} 
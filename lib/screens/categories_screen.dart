import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ahaar/models/food_category.dart';
import 'package:quick_ahaar/providers/category_provider.dart';
import 'package:quick_ahaar/screens/category_items_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3/2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryItemsScreen(
                    categoryId: category.id,
                    categoryName: category.name,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      category.color.withOpacity(0.7),
                      category.color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final categories = [
  FoodCategory(
    id: 'c1',
    name: 'Breakfast',
    icon: Icons.breakfast_dining,
    color: Colors.orange,
  ),
  FoodCategory(
    id: 'c2',
    name: 'Lunch',
    icon: Icons.lunch_dining,
    color: Colors.green,
  ),
  FoodCategory(
    id: 'c3',
    name: 'Dinner',
    icon: Icons.dinner_dining,
    color: Colors.blue,
  ),
  FoodCategory(
    id: 'c4',
    name: 'Snacks',
    icon: Icons.restaurant_menu,
    color: Colors.purple,
  ),
  FoodCategory(
    id: 'c5',
    name: 'Beverages',
    icon: Icons.local_drink,
    color: Colors.red,
  ),
  FoodCategory(
    id: 'c6',
    name: 'Desserts',
    icon: Icons.cake,
    color: Colors.pink,
  ),
]; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quick_ahaar/models/food_category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  Future<List<FoodCategory>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FoodCategory(
          id: doc.id,
          name: data['name'] ?? '',
          icon: IconData(data['icon'] ?? Icons.fastfood.codePoint, fontFamily: 'MaterialIcons'),
          color: Color(data['color'] ?? Colors.orange.value),
        );
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      // Return default categories if fetching fails
      return [
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
    }
  }

  Future<void> addCategory(FoodCategory category) async {
    try {
      await _firestore.collection(_collection).add({
        'name': category.name,
        'icon': category.icon.codePoint,
        'color': category.color.value,
      });
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(String id, FoodCategory category) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'name': category.name,
        'icon': category.icon.codePoint,
        'color': category.color.value,
      });
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  Future<void> initializeSampleCategories() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      if (snapshot.docs.isEmpty) {
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

        for (var category in categories) {
          await addCategory(category);
        }
      }
    } catch (e) {
      print('Error initializing sample categories: $e');
      rethrow;
    }
  }
} 
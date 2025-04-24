import 'package:flutter/foundation.dart';
import 'package:quick_ahaar/models/food_category.dart';
import 'package:quick_ahaar/services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<FoodCategory> _categories = [];
  bool _isLoading = false;

  List<FoodCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      print('Error loading categories: $e');
      _categories = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(FoodCategory category) async {
    try {
      await _categoryService.addCategory(category);
      await loadCategories();
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(String id, FoodCategory category) async {
    try {
      await _categoryService.updateCategory(id, category);
      await loadCategories();
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }
} 
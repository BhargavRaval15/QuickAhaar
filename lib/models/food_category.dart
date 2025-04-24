import 'package:flutter/material.dart';

class FoodCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory FoodCategory.fromMap(String id, Map<String, dynamic> map) {
    return FoodCategory(
      id: id,
      name: map['name'] ?? '',
      icon: IconData(map['icon'] ?? 0, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
    };
  }
} 
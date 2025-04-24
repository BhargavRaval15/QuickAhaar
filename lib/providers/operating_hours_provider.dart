import 'package:flutter/material.dart';
import 'package:quick_ahaar/models/operating_hours.dart';
import 'package:quick_ahaar/services/operating_hours_service.dart';

class OperatingHoursProvider with ChangeNotifier {
  final OperatingHoursService _service = OperatingHoursService();
  OperatingHours? _operatingHours;
  bool _isLoading = false;

  OperatingHours? get operatingHours => _operatingHours;
  bool get isLoading => _isLoading;

  Future<void> loadOperatingHours() async {
    _isLoading = true;
    notifyListeners();

    try {
      _operatingHours = await _service.getOperatingHours();
    } catch (e) {
      debugPrint('Error loading operating hours: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOperatingHours(OperatingHours hours) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateOperatingHours(hours);
      _operatingHours = hours;
    } catch (e) {
      debugPrint('Error updating operating hours: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> isWithinOperatingHours() async {
    return await _service.isWithinOperatingHours();
  }
} 
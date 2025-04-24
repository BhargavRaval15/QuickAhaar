import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_ahaar/models/operating_hours.dart';

class OperatingHoursService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'operating_hours';

  Future<OperatingHours> getOperatingHours() async {
    final doc = await _firestore.collection(_collection).doc('current').get();
    if (!doc.exists) {
      // Create default operating hours if they don't exist
      final defaultHours = OperatingHours(
        id: 'current',
        openHour: 9,
        openMinute: 0,
        closeHour: 17,
        closeMinute: 0,
        isOpen: true,
      );
      await _firestore
          .collection(_collection)
          .doc('current')
          .set(defaultHours.toMap());
      return defaultHours;
    }
    return OperatingHours.fromMap(doc.data()!);
  }

  Future<void> updateOperatingHours(OperatingHours hours) async {
    await _firestore
        .collection(_collection)
        .doc('current')
        .update(hours.toMap());
  }

  Future<bool> isWithinOperatingHours() async {
    final hours = await getOperatingHours();
    return hours.isWithinOperatingHours();
  }
} 
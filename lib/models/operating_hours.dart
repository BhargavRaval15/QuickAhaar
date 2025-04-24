import 'package:cloud_firestore/cloud_firestore.dart';

class OperatingHours {
  final String id;
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;
  final bool isOpen;

  OperatingHours({
    required this.id,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    required this.isOpen,
  });

  factory OperatingHours.fromMap(Map<String, dynamic> map) {
    return OperatingHours(
      id: map['id'] ?? '',
      openHour: map['openHour'] ?? 9,
      openMinute: map['openMinute'] ?? 0,
      closeHour: map['closeHour'] ?? 17,
      closeMinute: map['closeMinute'] ?? 0,
      isOpen: map['isOpen'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'openHour': openHour,
      'openMinute': openMinute,
      'closeHour': closeHour,
      'closeMinute': closeMinute,
      'isOpen': isOpen,
    };
  }

  bool isWithinOperatingHours() {
    if (!isOpen) return false;

    final now = DateTime.now();
    final openTime = DateTime(
      now.year,
      now.month,
      now.day,
      openHour,
      openMinute,
    );
    final closeTime = DateTime(
      now.year,
      now.month,
      now.day,
      closeHour,
      closeMinute,
    );

    return now.isAfter(openTime) && now.isBefore(closeTime);
  }

  String getFormattedOpenTime() {
    return '${openHour.toString().padLeft(2, '0')}:${openMinute.toString().padLeft(2, '0')}';
  }

  String getFormattedCloseTime() {
    return '${closeHour.toString().padLeft(2, '0')}:${closeMinute.toString().padLeft(2, '0')}';
  }
} 
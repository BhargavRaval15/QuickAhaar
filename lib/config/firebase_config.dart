import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCubWHnbC9cJgcNxMyiRxTCMMEAkuPNLn0',
          appId: '1:498954061516:web:df6f3b882a696a27956469',
          messagingSenderId: '498954061516',
          projectId: 'quickahaar-7fd39',
          storageBucket: 'quickahaar-7fd39.firebasestorage.app',
        ),
      );
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }
} 
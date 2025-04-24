import 'package:firebase_core/firebase_core.dart';

class FirebaseWebConfig {
  static const firebaseConfig = {
    'apiKey': 'AIzaSyCubWHnbC9cJgcNxMyiRxTCMMEAkuPNLn0',
    'authDomain': 'quickahaar-7fd39.firebaseapp.com',
    'projectId': 'quickahaar-7fd39',
    'storageBucket': 'quickahaar-7fd39.firebasestorage.app',
    'messagingSenderId': '498954061516',
    'appId': '1:498954061516:web:df6f3b882a696a27956469',
    'measurementId': 'G-KXY0XE3V1K'
  };

  static Future<void> initializeFirebaseWeb() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseConfig['apiKey']!,
        authDomain: firebaseConfig['authDomain']!,
        projectId: firebaseConfig['projectId']!,
        storageBucket: firebaseConfig['storageBucket']!,
        messagingSenderId: firebaseConfig['messagingSenderId']!,
        appId: firebaseConfig['appId']!,
        measurementId: firebaseConfig['measurementId']!,
      ),
    );
  }
} 
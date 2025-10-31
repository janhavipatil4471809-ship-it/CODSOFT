import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web configuration
      return const FirebaseOptions(
        apiKey: "AIzaSyD2ayVCKl6us1PJjH0MGSICPyvHoIHiTuT",
        authDomain: "university-attendance-f3690.firebaseapp.com",
        projectId: "university-attendance-f3690",
        storageBucket: "university-attendance-f3690.appspot.com",
        messagingSenderId: "42549358601",
        appId: "1:42549358601:web:4bb2606a22d4b8fb87fa98",
        measurementId: "G-MT29BCM04V",
      );
    }

    // Default for others
    throw UnsupportedError('Unsupported platform');
  }
}

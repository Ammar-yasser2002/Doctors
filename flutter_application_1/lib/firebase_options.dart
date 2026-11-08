// File generated for Doctors App Firebase configuration
// Connected to project: ammar-cf63e
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBYgpjXzyr-Uu_D7eRfec68vDFYgKXTc4U',
    appId: '1:210015995030:web:511c38004fa6452c5ceeb7',
    messagingSenderId: '210015995030',
    projectId: 'ammar-cf63e',
    authDomain: 'ammar-cf63e.firebaseapp.com',
    storageBucket: 'ammar-cf63e.firebasestorage.app',
    measurementId: 'G-1E84LNH637',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrLMRZoqKL68e_ssUIzHIxedTU8mE9mzw',
    appId: '1:210015995030:android:533d0fd2c0839c435ceeb7',
    messagingSenderId: '210015995030',
    projectId: 'ammar-cf63e',
    storageBucket: 'ammar-cf63e.firebasestorage.app',
  );
}

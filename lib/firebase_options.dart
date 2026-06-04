import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static bool get isConfigured => currentPlatform.apiKey != 'demo-api-key';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDBA6Xi6DDy4-CxiSYwtsc5wREFY1mHXeo',
    appId: '1:712373546485:web:fb2ae86fd5017ec38384bc',
    messagingSenderId: '712373546485',
    projectId: 'foodhub-klv-2026',
    authDomain: 'foodhub-klv-2026.firebaseapp.com',
    storageBucket: 'foodhub-klv-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDozeHDL_2q8MbEN_0k0gtY-ondk4FlqMs',
    appId: '1:712373546485:android:f69a79d91ba92c378384bc',
    messagingSenderId: '712373546485',
    projectId: 'foodhub-klv-2026',
    storageBucket: 'foodhub-klv-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:ios:foodhubdemo',
    messagingSenderId: '000000000000',
    projectId: 'foodhub-demo',
    iosBundleId: 'com.example.foodhub',
    storageBucket: 'foodhub-demo.appspot.com',
  );
}

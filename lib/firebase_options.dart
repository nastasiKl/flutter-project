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
    apiKey: 'demo-api-key',
    appId: '1:000000000000:web:foodhubdemo',
    messagingSenderId: '000000000000',
    projectId: 'foodhub-demo',
    authDomain: 'foodhub-demo.firebaseapp.com',
    storageBucket: 'foodhub-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:android:foodhubdemo',
    messagingSenderId: '000000000000',
    projectId: 'foodhub-demo',
    storageBucket: 'foodhub-demo.appspot.com',
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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);

class FirebaseBootstrap {
  static Future<bool> initialize() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      return false;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      return Firebase.apps.isNotEmpty;
    } on Object {
      return false;
    }
  }
}

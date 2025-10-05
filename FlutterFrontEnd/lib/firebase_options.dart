import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // This will support Android and iOS in the future
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfAj0Rf-Yq-pIYebRAhAKlfwIkd5FE-EQ',
    appId: '1:893793179289:web:9d90e2da787c61ebf00a08',
    messagingSenderId: '893793179289',
    projectId: 'health-project-afff3',
    authDomain: 'health-project-afff3.firebaseapp.com',
    storageBucket: 'health-project-afff3.firebasestorage.app',
    measurementId: 'G-XFRFYQPN2Q',
  );

  // We can fill these out later when we configure for Android and iOS
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: 'PLACEHOLDER',
    messagingSenderId: 'PLACEHOLDER',
    projectId: 'PLACEHOLDER',
    storageBucket: 'PLACEHOLDER',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: 'PLACEHOLDER',
    messagingSenderId: 'PLACEHOLDER',
    projectId: 'PLACEHOLDER',
    storageBucket: 'PLACEHOLDER',
    iosBundleId: 'com.example.healthTrack',
  );
}
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default FirebaseOptions for the available platforms
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not available for this platform.',
        );
    }
  }

  /// Firebase options for web platform
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDoCVEoe1g4hF2ztl4RHoOgEQKLCAL6P1o',
    appId: '1:248380538875:web:f1b51d92e99b1a3c30d55e',
    messagingSenderId: '248380538875',
    projectId: 'book-track-d1d19',
    authDomain: 'book-track-d1d19.firebaseapp.com',
    storageBucket: 'book-track-d1d19.appspot.com',
    // Remove measurement ID if not using Google Analytics
  );

  /// Firebase options for Android platform
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDoCVEoe1g4hF2ztl4RHoOgEQKLCAL6P1o',
    appId: '1:248380538875:android:4c52aaddca698d2330d55e',
    messagingSenderId: '248380538875',
    projectId: 'book-track-d1d19',
    storageBucket: 'book-track-d1d19.appspot.com',
  );

  /// Firebase options for iOS platform
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDoCVEoe1g4hF2ztl4RHoOgEQKLCAL6P1o',
    appId: '1:248380538875:ios:8cf6899bdfb66fd430d55e',
    messagingSenderId: '248380538875',
    projectId: 'book-track-d1d19',
    storageBucket: 'book-track-d1d19.appspot.com',
    iosBundleId: 'tamanna.booktracker',
  );

  /// Firebase options for macOS platform
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDoCVEoe1g4hF2ztl4RHoOgEQKLCAL6P1o',
    appId: '1:248380538875:ios:8cf6899bdfb66fd430d55e',
    messagingSenderId: '248380538875',
    projectId: 'book-track-d1d19',
    storageBucket: 'book-track-d1d19.appspot.com',
    iosBundleId: 'tamanna.booktracker',
  );

  /// Firebase options for Windows platform
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDoCVEoe1g4hF2ztl4RHoOgEQKLCAL6P1o',
    appId: '1:248380538875:web:f1b51d92e99b1a3c30d55e',
    messagingSenderId: '248380538875',
    projectId: 'book-track-d1d19',
    storageBucket: 'book-track-d1d19.appspot.com',
  );

  /// Firebase options for Linux platform
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDoCVEoe1g4hF2ztl4RHoOgEQKLCAL6P1o',
    appId: '1:248380538875:web:f1b51d92e99b1a3c30d55e',
    messagingSenderId: '248380538875',
    projectId: 'book-track-d1d19',
    storageBucket: 'book-track-d1d19.appspot.com',
  );
}

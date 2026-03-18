import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart' show TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAzqB9IU974qC0617S8xbEJg43GlIQfRPM',
    appId: '1:393628478650:web:5903b889b872b55838a683',
    messagingSenderId: '393628478650',
    projectId: 'map-to-market',
    storageBucket: 'map-to-market.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzqB9IU974qC0617S8xbEJg43GlIQfRPM',
    appId: '1:393628478650:android:5903b889b872b55838a683',
    messagingSenderId: '393628478650',
    projectId: 'map-to-market',
    storageBucket: 'map-to-market.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAzqB9IU974qC0617S8xbEJg43GlIQfRPM',
    appId: '1:393628478650:ios:5903b889b872b55838a683',
    messagingSenderId: '393628478650',
    projectId: 'map-to-market',
    storageBucket: 'map-to-market.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAzqB9IU974qC0617S8xbEJg43GlIQfRPM',
    appId: '1:393628478650:macos:5903b889b872b55838a683',
    messagingSenderId: '393628478650',
    projectId: 'map-to-market',
    storageBucket: 'map-to-market.firebasestorage.app',
  );
}

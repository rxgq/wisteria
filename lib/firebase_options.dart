// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCQLVllH_Sof8eqYLxsybcapNzcuxEVobQ',
    appId: '1:8314997661:web:3a04c3b25ffed4c8ec3d74',
    messagingSenderId: '8314997661',
    projectId: 'wisteria-1c25f',
    authDomain: 'wisteria-1c25f.firebaseapp.com',
    storageBucket: 'wisteria-1c25f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByW624lK7UKcRb4B15rphZrHAhG31XeGI',
    appId: '1:8314997661:android:f6aee03f5bbac649ec3d74',
    messagingSenderId: '8314997661',
    projectId: 'wisteria-1c25f',
    storageBucket: 'wisteria-1c25f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBcYzeO_JW5XxOoLlfBv0tCaJR6-WPMGkM',
    appId: '1:8314997661:ios:26a797b89a4636a0ec3d74',
    messagingSenderId: '8314997661',
    projectId: 'wisteria-1c25f',
    storageBucket: 'wisteria-1c25f.firebasestorage.app',
    iosBundleId: 'com.example.wisteria',
  );
}

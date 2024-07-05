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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBJEd20RU-Y_GgBz5mqzHwb__ejpPpoJy4',
    appId: '1:590577079005:web:a3754ed098bb5c73108134',
    messagingSenderId: '590577079005',
    projectId: 'work-day-a2529',
    authDomain: 'work-day-a2529.firebaseapp.com',
    storageBucket: 'work-day-a2529.appspot.com',
    measurementId: 'G-NBPLLHDV7S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVadHO3pBI2xTdkkUG5vLEWKOJ0USFTIY',
    appId: '1:590577079005:android:0815800f03d11b9c108134',
    messagingSenderId: '590577079005',
    projectId: 'work-day-a2529',
    storageBucket: 'work-day-a2529.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDggjOohwM47vcqLM37lTFZeOZlBF7fK0s',
    appId: '1:590577079005:ios:9692f780167f9236108134',
    messagingSenderId: '590577079005',
    projectId: 'work-day-a2529',
    storageBucket: 'work-day-a2529.appspot.com',
    iosBundleId: 'com.example.test',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDggjOohwM47vcqLM37lTFZeOZlBF7fK0s',
    appId: '1:590577079005:ios:9692f780167f9236108134',
    messagingSenderId: '590577079005',
    projectId: 'work-day-a2529',
    storageBucket: 'work-day-a2529.appspot.com',
    iosBundleId: 'com.example.test',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBJEd20RU-Y_GgBz5mqzHwb__ejpPpoJy4',
    appId: '1:590577079005:web:6e56bf33b4c40df8108134',
    messagingSenderId: '590577079005',
    projectId: 'work-day-a2529',
    authDomain: 'work-day-a2529.firebaseapp.com',
    storageBucket: 'work-day-a2529.appspot.com',
    measurementId: 'G-M211XLM4T1',
  );
}

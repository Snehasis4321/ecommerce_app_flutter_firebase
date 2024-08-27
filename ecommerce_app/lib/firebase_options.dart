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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEQrg45D7XgjW0ouJdusG8xNM--SbF7lY',
    appId: '1:705724924854:android:73f24164b273fcf8c4b717',
    messagingSenderId: '705724924854',
    projectId: 'contacts-app-b5a05',
    storageBucket: 'contacts-app-b5a05.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSmUcRo7dTnvFvPtUsZWGr_qbszANhtWA',
    appId: '1:705724924854:ios:a4d5856f75e2f6ccc4b717',
    messagingSenderId: '705724924854',
    projectId: 'contacts-app-b5a05',
    storageBucket: 'contacts-app-b5a05.appspot.com',
    androidClientId: '705724924854-r3b0ntdh2fi13v9psgc8dgl9ds4hf4nl.apps.googleusercontent.com',
    iosClientId: '705724924854-tvhiprg0kg1lvc77j8l8r3d8rr5va3bm.apps.googleusercontent.com',
    iosBundleId: 'com.example.ecommerceApp',
  );

}
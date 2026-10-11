// File generated for FlutterFire support.
// ignore_for_file: type=lint
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
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForKapsulDolapWebPlatform012',
    appId: '1:300830567303:web:kapsuldolap39webid',
    messagingSenderId: '300830567303',
    projectId: 'fir-demo-project',
    authDomain: 'fir-demo-project.firebaseapp.com',
    storageBucket: 'fir-demo-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForKapsulDolapAndroidPlatform',
    appId: '1:300830567303:android:9b9ba2ce17104d0c',
    messagingSenderId: '300830567303',
    projectId: 'fir-demo-project',
    storageBucket: 'fir-demo-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForKapsulDolapIosPlatform0001',
    appId: '1:300830567303:ios:09b1ab1d3ca29bda',
    messagingSenderId: '300830567303',
    projectId: 'fir-demo-project',
    storageBucket: 'fir-demo-project.appspot.com',
    iosBundleId: 'com.example.kapsulDolap',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForKapsulDolapMacosPlatform001',
    appId: '1:300830567303:ios:09b1ab1d3ca29bda',
    messagingSenderId: '300830567303',
    projectId: 'fir-demo-project',
    storageBucket: 'fir-demo-project.appspot.com',
    iosBundleId: 'com.example.kapsulDolap',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForKapsulDolapWindowsPlatform',
    appId: '1:300830567303:web:kapsuldolap39winid',
    messagingSenderId: '300830567303',
    projectId: 'fir-demo-project',
    authDomain: 'fir-demo-project.firebaseapp.com',
    storageBucket: 'fir-demo-project.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForKapsulDolapLinuxPlatform01',
    appId: '1:300830567303:web:kapsuldolap39linuxid',
    messagingSenderId: '300830567303',
    projectId: 'fir-demo-project',
    authDomain: 'fir-demo-project.firebaseapp.com',
    storageBucket: 'fir-demo-project.appspot.com',
  );
}

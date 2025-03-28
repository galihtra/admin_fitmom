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
    apiKey: 'AIzaSyBGNXtlOC6UE2EtLRDmD_gTqGTIUuMRi24',
    appId: '1:161249607054:web:010c3d96f38951a569f8df',
    messagingSenderId: '161249607054',
    projectId: 'fitmom-guide',
    authDomain: 'fitmom-guide.firebaseapp.com',
    storageBucket: 'fitmom-guide.firebasestorage.app',
    measurementId: 'G-SLL84Q97L7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_MKM_j5vh96H9Ll3s5FKqfldWkp3YmAA',
    appId: '1:161249607054:android:5bf04e793f25808969f8df',
    messagingSenderId: '161249607054',
    projectId: 'fitmom-guide',
    storageBucket: 'fitmom-guide.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_fCs4-YaSNtBLulALOvG835kb2TzrPBA',
    appId: '1:161249607054:ios:152d5914ab31301c69f8df',
    messagingSenderId: '161249607054',
    projectId: 'fitmom-guide',
    storageBucket: 'fitmom-guide.firebasestorage.app',
    androidClientId: '161249607054-4clhmh061bledtdoqh6j9vi8l39pgjvb.apps.googleusercontent.com',
    iosClientId: '161249607054-oavp2ki7l8950919odm0ea6rpnkapco7.apps.googleusercontent.com',
    iosBundleId: 'com.example.adminFitmom',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_fCs4-YaSNtBLulALOvG835kb2TzrPBA',
    appId: '1:161249607054:ios:152d5914ab31301c69f8df',
    messagingSenderId: '161249607054',
    projectId: 'fitmom-guide',
    storageBucket: 'fitmom-guide.firebasestorage.app',
    androidClientId: '161249607054-4clhmh061bledtdoqh6j9vi8l39pgjvb.apps.googleusercontent.com',
    iosClientId: '161249607054-oavp2ki7l8950919odm0ea6rpnkapco7.apps.googleusercontent.com',
    iosBundleId: 'com.example.adminFitmom',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBGNXtlOC6UE2EtLRDmD_gTqGTIUuMRi24',
    appId: '1:161249607054:web:77a5e386f8423a0369f8df',
    messagingSenderId: '161249607054',
    projectId: 'fitmom-guide',
    authDomain: 'fitmom-guide.firebaseapp.com',
    storageBucket: 'fitmom-guide.firebasestorage.app',
    measurementId: 'G-L0P2K6BQ69',
  );
}

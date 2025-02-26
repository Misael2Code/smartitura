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
    apiKey: 'AIzaSyDiS8grISYU5V1KVNqn65V_Kqmda2kkeP8',
    appId: '1:970700569187:web:c0cfdf357f408bef651656',
    messagingSenderId: '970700569187',
    projectId: 'smartitura',
    authDomain: 'smartitura.firebaseapp.com',
    storageBucket: 'smartitura.firebasestorage.app',
    measurementId: 'G-MF82YKZJ55',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAuFxo-msFHvlYIOjXzC0V1fI3v-u2NTkg',
    appId: '1:970700569187:android:e8a9a9246fe33a86651656',
    messagingSenderId: '970700569187',
    projectId: 'smartitura',
    storageBucket: 'smartitura.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDg3fXJDBmImMiI2jvqrY09jOPAsuRiMBQ',
    appId: '1:970700569187:ios:461a63489330bd9d651656',
    messagingSenderId: '970700569187',
    projectId: 'smartitura',
    storageBucket: 'smartitura.firebasestorage.app',
    iosBundleId: 'com.misael2code.smartitura',
  );
}

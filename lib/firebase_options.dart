/// ONYX Firebase Configuration — Auto-generated placeholder.
///
/// Run `flutterfire configure` to populate with your real Firebase project
/// credentials. This file provides the structure so the app compiles.
///
/// See: https://firebase.google.com/docs/flutter/setup
library;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for ${defaultTargetPlatform.name}. '
          'Run `flutterfire configure` to set up your Firebase project.',
        );
    }
  }

  // ── Android ────────────────────────────────────────────────────
  // TODO: Replace with values from `flutterfire configure`

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0BveEogsECHvOpgxuo9i0jYL581vvxFw',
    appId: '1:304898707316:android:738599a185e82ca1a4a621',
    messagingSenderId: '304898707316',
    projectId: 'onyx-b83ef',
    storageBucket: 'onyx-b83ef.firebasestorage.app',
  );
  // ── iOS ────────────────────────────────────────────────────────
  // TODO: Replace with values from `flutterfire configure`

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4D1HIaHy6eyFv7CrHWubU07yIgAxRt6U',
    appId: '1:304898707316:ios:f1e344b10a38bdbda4a621',
    messagingSenderId: '304898707316',
    projectId: 'onyx-b83ef',
    storageBucket: 'onyx-b83ef.firebasestorage.app',
    iosClientId: '304898707316-n8bthn23qgfo71lsgichgkrgua7cfebr.apps.googleusercontent.com',
    iosBundleId: 'com.onyx.onyx',
  );
  // ── Web ────────────────────────────────────────────────────────
  // TODO: Replace with values from `flutterfire configure`

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDHUTlPPt9pBaigrAbtiPEXEbQCy7lpaRQ',
    appId: '1:304898707316:web:ca2c64574048acdda4a621',
    messagingSenderId: '304898707316',
    projectId: 'onyx-b83ef',
    authDomain: 'onyx-b83ef.firebaseapp.com',
    storageBucket: 'onyx-b83ef.firebasestorage.app',
    measurementId: 'G-S4KH5JZS6E',
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/firebase_bootstrap.dart';
import 'app/pairra_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Switches to Firebase-backed auth + Firestore persistence when Firebase is
  // configured; otherwise returns no overrides and the app runs on the
  // in-memory mocks (so it works before any credentials exist).
  final overrides = await firebaseBootstrap();

  runApp(ProviderScope(overrides: overrides, child: const PairraApp()));
}

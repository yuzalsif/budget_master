// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbm/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //TODO: Implement this features when ready
  // await GoogleSignIn.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // We only need to initialize third-party packages that require it.
  //TODO: Implement this features when ready
  // await GoogleSignIn.instance.initialize();

  // Riverpod's ProviderScope will now handle everything else for us.
  runApp(const ProviderScope(child: MyApp()));
}

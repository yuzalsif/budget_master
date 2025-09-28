import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/app/app.dart';

void main() {
  // Ensure that widget binding is initialized before doing anything.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope is what makes Riverpod work. It stores the state of all providers.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

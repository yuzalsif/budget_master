import 'package:budget_master/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/app/theme/app_theme.dart';
import 'package:budget_master/core/providers/database_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectboxAsyncValue = ref.watch(objectboxProvider);

    return MaterialApp(
      title: 'Budget Master',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: objectboxAsyncValue.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(
            body: Center(child: Text('Error initializing database: $err'))),
        data: (isar) =>
            const HomePage(), // When DB is ready, show our home page
      ),
    );
  }
}

// This will be our temporary home page to navigate to other features.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AccountsScreen()),
            );
          },
          child: const Text('Manage Accounts'),
        ),
      ),
    );
  }
}

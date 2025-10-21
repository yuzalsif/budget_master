import 'package:budget_master/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:budget_master/features/settings/application/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/app/theme/app_theme.dart';
import 'package:budget_master/core/providers/database_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectboxAsyncValue = ref.watch(objectboxProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Budget Master',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: objectboxAsyncValue.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Error initializing database: $err')),
        ),
        data: (isar) =>
            const DashboardScreen(), 
      ),
    );
  }
}

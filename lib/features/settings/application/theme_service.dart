// lib/features/settings/application/theme_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeServiceProvider = FutureProvider<ThemeService>((ref) async {
  final service = ThemeService();
  await service.init();
  return service;
});

// This provider now depends on the FutureProvider.
final themeProvider = StateProvider<ThemeMode>((ref) {
  // We watch the service. When it's ready, we get the initial theme.
  final themeService = ref.watch(themeServiceProvider);
  // Return the data if available, otherwise default to system.
  return themeService.asData?.value.getThemeMode() ?? ThemeMode.system;
});

class ThemeService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  ThemeMode getThemeMode() {
    final themeIndex = _prefs.getInt('themeMode') ?? ThemeMode.system.index;
    return ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt('themeMode', mode.index);
  }
}

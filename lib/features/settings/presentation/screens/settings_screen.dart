// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbm/features/settings/application/backup_service.dart';
import 'package:jbm/features/settings/application/theme_service.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Helper to format the backup date string for display
  String _formatBackupDate(String isoDate) {
    if (isoDate == 'Never' || isoDate == 'Loading...') return isoDate;
    try {
      final date = DateTime.parse(isoDate);
      // A user-friendly date format
      return DateFormat.yMMMd().add_jms().format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all the providers needed for this screen
    final currentTheme = ref.watch(themeProvider);
    final lastBackup = ref.watch(lastBackupProvider);
    final isBackingUp = ref.watch(backupInProgressProvider);

    // Watch the asynchronous provider for the backup service itself.
    // This will give us its state: loading, error, or data (the service instance).
    final backupServiceAsync = ref.watch(backupServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // --- Theme Section ---
          ListTile(
            title: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(
              currentTheme.name[0].toUpperCase() +
                  currentTheme.name.substring(1),
            ),
            onTap: () {
              // Dialog to change the app's theme
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Choose Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ThemeMode.values.map((theme) {
                      return RadioListTile<ThemeMode>(
                        title: Text(
                          theme.name[0].toUpperCase() + theme.name.substring(1),
                        ),
                        value: theme,
                        groupValue: currentTheme,
                        onChanged: (value) async {
                          if (value != null) {
                            // Update the theme state and persist the choice
                            ref.read(themeProvider.notifier).state = value;
                            final themeService = await ref.read(
                              themeServiceProvider.future,
                            );
                            await themeService.setThemeMode(value);
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // --- Backup Section ---
          ListTile(
            title: Text(
              'Backup & Restore',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // Use AsyncValue.when to handle the loading/error/data states of the backup service
          backupServiceAsync.when(
            loading: () => const ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Initializing backup service...'),
            ),
            error: (err, stack) => ListTile(
              leading: Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Backup service failed to load'),
              subtitle: Text('$err'),
            ),
            data: (backupService) => ListTile(
              // The UI is built only when the backupService is ready
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Backup to Google Drive'),
              subtitle: Text('Last backup: ${_formatBackupDate(lastBackup)}'),
              trailing: isBackingUp ? const CircularProgressIndicator() : null,
              // onTap: isBackingUp
              //     ? null // Disable button while backup is in progress
              //     : () async {
              //         ref.read(backupInProgressProvider.notifier).state = true;
              //         final result = await backupService.backupToGoogleDrive();
              //         ref.read(backupInProgressProvider.notifier).state = false;

              //         // After backup, refresh the last backup info by reading it again
              //         ref.read(lastBackupProvider.notifier).state =
              //             backupService.getLastBackupInfo();

              //         if (context.mounted) {
              //           ScaffoldMessenger.of(
              //             context,
              //           ).showSnackBar(SnackBar(content: Text(result)));
              //         }
              //       },
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature will be released soon!'),
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('Restore from Google Drive'),
            subtitle: const Text('This will overwrite all local data.'),
            onTap: () {
              // TODO: Implement restore logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This feature will be released soon!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

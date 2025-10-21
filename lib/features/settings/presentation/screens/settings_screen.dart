import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/features/settings/application/backup_service.dart';
import 'package:budget_master/features/settings/application/theme_service.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _formatBackupDate(String isoDate) {
    if (isoDate == 'Never' || isoDate == 'Loading...') return isoDate;
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat.yMMMd().add_jms().format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final lastBackup = ref.watch(lastBackupProvider);
    final isBackingUp = ref.watch(backupInProgressProvider);

   
    final backupServiceAsync = ref.watch(backupServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
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

          ListTile(
            title: Text(
              'Backup & Restore',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
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
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Backup to Google Drive'),
              subtitle: Text('Last backup: ${_formatBackupDate(lastBackup)}'),
              trailing: isBackingUp ? const CircularProgressIndicator() : null,
            
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

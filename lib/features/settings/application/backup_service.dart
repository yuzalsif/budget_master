// lib/features/settings/application/backup_service.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'package:budget_master/core/providers/database_provider.dart';
import 'package:budget_master/objectbox.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// An authenticated HTTP client... (this class is unchanged)
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  // It waits for the database to be ready first.
  final store = await ref.watch(objectboxProvider.future);

  // Then it creates and initializes the service.
  final service = BackupService(store);
  await service.init();
  return service;
});

// This provider depends on the service being ready.
final lastBackupProvider = StateProvider<String>((ref) {
  final backupService = ref.watch(backupServiceProvider);
  return backupService.asData?.value.getLastBackupInfo() ?? 'Loading...';
});

final backupInProgressProvider = StateProvider<bool>((ref) => false);

class BackupService {
  static const _backupFileName = 'budget_master_backup.db';
  late SharedPreferences _prefs;
  final Store _store;

  BackupService(this._store);

  // --- THIS IS THE FINAL FIX ---
  // Use the singleton instance provided by the package.
  // The scopes are now handled by the initialize() call in main.dart.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // -----------------------------

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getLastBackupInfo() {
    return _prefs.getString('lastBackup') ?? 'Never';
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: [drive.DriveApi.driveFileScope],
      );

      final authClient = googleUser.authorizationClient;

      final headers = await authClient.authorizationHeaders([
        drive.DriveApi.driveFileScope,
      ], promptIfNecessary: true);

      if (headers == null) {
        print('Could not get authorization headers.');
        return null;
      }

      final client = GoogleAuthClient(headers);
      return drive.DriveApi(client);
    } catch (e) {
      print('Error during Google authentication: $e');
      return null;
    }
  }

  Future<String> backupToGoogleDrive() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return "Backup cancelled: Could not sign in.";

    final dbPath = p.join(_store.directoryPath, 'data.mdb');
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) return "Error: Database file not found.";

    try {
      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName' and trashed = false",
        spaces: 'drive',
      );

      final driveFile = drive.File()..name = _backupFileName;
      final media = drive.Media(dbFile.openRead(), await dbFile.length());

      if (fileList.files!.isEmpty) {
        await driveApi.files.create(driveFile, uploadMedia: media);
      } else {
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(driveFile, fileId, uploadMedia: media);
      }

      final backupTime = DateTime.now().toIso8601String();
      await _prefs.setString('lastBackup', backupTime);
      return 'Backup Successful!';
    } catch (e) {
      print('Backup error: $e');
      return 'Backup Failed: An error occurred.';
    }
  }
}

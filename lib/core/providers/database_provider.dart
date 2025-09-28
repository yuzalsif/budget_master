import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/category.dart';
import 'package:budget_master/domain/models/transaction.dart';

// A provider that asynchronously initializes Isar
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  if (Isar.instanceNames.isEmpty) {
    return await Isar.open(
      [
        AccountSchema,
        CategorySchema,
        TransactionSchema,
      ],
      directory: dir.path,
      inspector: true,
    );
  }
  return Future.value(Isar.getInstance());
});

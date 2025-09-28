// lib/features/accounts/application/account_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:budget_master/core/providers/database_provider.dart';
import 'package:budget_master/domain/models/account.dart';

// This provider will give us a stream of the list of accounts.
// The UI will rebuild automatically when this stream emits a new list.
final accountsStreamProvider = StreamProvider.autoDispose<List<Account>>((ref) {
  final isar = ref.watch(isarProvider).value; // Get the Isar instance

  if (isar != null) {
    // .watch(fireImmediately: true) gives us the current data right away
    // and then listens for any changes in the Account collection.
    return isar.accounts.where().watch(fireImmediately: true);
  }

  return Stream.value([]); // Return an empty stream if isar is not ready
});

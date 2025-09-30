import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbm/domain/models/account.dart';
import 'package:jbm/features/accounts/application/account_service.dart';

// This provider just holds the state (the list of accounts)
final accountsProvider = StateProvider<List<Account>>((ref) {
  // It gets the initial list from our service.
  return ref.read(accountServiceProvider).getAllAccounts();
});

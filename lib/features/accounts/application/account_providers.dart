import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/features/accounts/application/account_service.dart';

final accountsProvider = StateProvider<List<Account>>((ref) {
  return ref.read(accountServiceProvider).getAllAccounts();
});

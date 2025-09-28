import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/core/providers/database_provider.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/objectbox.g.dart';

// Provider to access our service class
final accountServiceProvider = Provider<AccountService>((ref) {
  final store = ref.watch(objectboxProvider).value!;
  return AccountService(store.box<Account>());
});

class AccountService {
  final Box<Account> _box;

  AccountService(this._box);

  List<Account> getAllAccounts() {
    return _box.getAll();
  }

  void addAccount(Account account) {
    _box.put(account);
  }

    void updateAccount(Account account) {
    // ObjectBox's put() method handles both create and update.
    // If an object with the same ID is put, it's updated.
    // If the ID is 0 or doesn't exist, it's created.
    _box.put(account);
  }

  void deleteAccount(int accountId) {
    _box.remove(accountId);
  }
}

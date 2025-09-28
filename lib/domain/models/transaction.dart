import 'package:isar/isar.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/category.dart';

part 'transaction.g.dart';

enum TransactionType { deposit, withdrawal }

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late double amount;

  @enumerated
  late TransactionType type;

  late DateTime date;

  String? description;

  // IsarLink establishes a relationship between collections
  // This is how we know which account and category this transaction belongs to.
  final account = IsarLink<Account>();
  final category = IsarLink<Category>();

  Transaction();
}

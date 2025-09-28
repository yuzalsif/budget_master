import 'package:objectbox/objectbox.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/category.dart';

// Enum definition stays.
enum TransactionType { deposit, withdrawal }

@Entity()
class Transaction {
  @Id()
  int id = 0;

  late double amount;

  // --- THE FIX ---
  // Store as an integer. Default is 0, which matches TransactionType.deposit.
  int type = 0;
  // ---------------

  @Property(type: PropertyType.date)
  late DateTime date;

  String? description;

  final account = ToOne<Account>();
  final category = ToOne<Category>();

  Transaction();
}

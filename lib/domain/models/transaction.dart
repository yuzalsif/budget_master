import 'package:budget_master/domain/models/contact.dart';
import 'package:objectbox/objectbox.dart';
import 'package:budget_master/domain/models/account.dart';
import 'package:budget_master/domain/models/category.dart';

enum TransactionType { deposit, withdrawal }

@Entity()
class Transaction {
  @Id()
  int id = 0;

  late double amount;

  int type = 0;

  @Property(type: PropertyType.date)
  late DateTime date;

  String? description;

  final contact = ToOne<Contact>();

  final account = ToOne<Account>();
  final category = ToOne<Category>();

  Transaction();
}

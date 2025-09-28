import 'package:objectbox/objectbox.dart';

@Entity() // Changed from @collection
class Account {
  @Id() // Changed from Id
  int id = 0;

  @Unique() // Changed from @Index(unique: true)
  late String name;

  late double balance;

  // No-args constructor is required by ObjectBox
  Account();
}

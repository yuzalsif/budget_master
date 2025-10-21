import 'package:objectbox/objectbox.dart';

@Entity() 
class Account {
  @Id() 
  int id = 0;

  @Unique() 
  late String name;

  late double balance;

  Account();
}

import 'package:objectbox/objectbox.dart';

enum CategoryType { expense, income, investment, outing }

@Entity()
class Category {
  @Id()
  int id = 0;

  @Unique()
  late String name;


  int type = 0;

  Category();
}

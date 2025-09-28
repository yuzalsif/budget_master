import 'package:isar/isar.dart';

part 'category.g.dart';

enum CategoryType { expense, income, investment, outing }

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true)
  late String name; 

  @enumerated
  late CategoryType type;

  Category();
}

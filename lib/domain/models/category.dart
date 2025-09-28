import 'package:objectbox/objectbox.dart';

// The enum definition stays. It's our source of truth.
enum CategoryType { expense, income, investment, outing }

@Entity()
class Category {
  @Id()
  int id = 0;

  @Unique()
  late String name;

  // --- THE FIX ---
  // Store the enum's index as a simple integer.
  // No annotations needed. The default value is 0, which matches CategoryType.expense.
  int type = 0;
  // ---------------

  Category();
}

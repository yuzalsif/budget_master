import 'package:objectbox/objectbox.dart';

@Entity()
class Contact {
  @Id()
  int id = 0;

  @Unique()
  late String name;

  Contact();
}

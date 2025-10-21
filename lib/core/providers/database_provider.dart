import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:budget_master/objectbox.g.dart';

final objectboxProvider = FutureProvider<Store>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  final store = await openStore(
    directory: p.join(dir.path, "obx-budget-master"),
  );

  return store;
});

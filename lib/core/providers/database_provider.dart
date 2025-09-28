import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:budget_master/objectbox.g.dart'; 

// A provider that asynchronously initializes ObjectBox and provides the Store
final objectboxProvider = FutureProvider<Store>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  // The 'openStore' function is created by the code generator
  final store =
      await openStore(directory: p.join(dir.path, "obx-budget-master"));

  return store;
});

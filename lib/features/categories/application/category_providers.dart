// lib/features/categories/application/category_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbm/domain/models/category.dart';
import 'package:jbm/features/categories/application/category_service.dart';

final categoriesProvider = StateProvider<List<Category>>((ref) {
  return ref.read(categoryServiceProvider).getAllCategories();
});

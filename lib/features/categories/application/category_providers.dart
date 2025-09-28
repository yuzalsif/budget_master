// lib/features/categories/application/category_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/domain/models/category.dart';
import 'package:budget_master/features/categories/application/category_service.dart';

final categoriesProvider = StateProvider<List<Category>>((ref) {
  return ref.read(categoryServiceProvider).getAllCategories();
});

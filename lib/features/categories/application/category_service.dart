// lib/features/categories/application/category_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbm/core/providers/database_provider.dart';
import 'package:jbm/domain/models/category.dart';
import 'package:jbm/objectbox.g.dart';

// Provider to access our service class
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final store = ref.watch(objectboxProvider).value!;
  return CategoryService(store.box<Category>());
});

class CategoryService {
  final Box<Category> _box;

  CategoryService(this._box);

  List<Category> getAllCategories() {
    return _box.getAll();
  }

  void addCategory(Category category) {
    _box.put(category);
  }

  void updateCategory(Category category) {
    _box.put(category);
  }

  void deleteCategory(int categoryId) {
    _box.remove(categoryId);
  }
}

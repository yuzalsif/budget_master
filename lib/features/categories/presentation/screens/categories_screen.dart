import 'package:budget_master/features/categories/presentation/screens/category_detail_screen.dart';
import 'package:budget_master/features/categories/presentation/screens/category_totals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_master/domain/models/category.dart';
import 'package:budget_master/features/categories/application/category_providers.dart';
import 'package:budget_master/features/categories/presentation/screens/add_edit_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Category> categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CategoryTotalsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined),
                  title: Text('Category Totals'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                'No categories yet.\nTap the + button to add one!',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                // Get the enum from the integer
                final categoryType = CategoryType.values[category.type];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 8.0,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    leading: Icon(
                      _getIconForCategoryType(categoryType),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Text(
                      _getCategoryTypeName(categoryType),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoryDetailScreen(category: category),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditCategoryScreen(),
            ),
          );
        },
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForCategoryType(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return Icons.arrow_downward_rounded;
      case CategoryType.income:
        return Icons.arrow_upward_rounded;
      case CategoryType.investment:
        return Icons.trending_up_rounded;
      case CategoryType.outing:
        return Icons.directions_walk_rounded;
    }
  }

  // Helper function to get a display string for the enum
  String _getCategoryTypeName(CategoryType type) {
    // Take the enum name (e.g., "expense"), and capitalize the first letter.
    return type.name[0].toUpperCase() + type.name.substring(1);
  }
}

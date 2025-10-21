import 'package:budget_master/domain/models/category.dart';
import 'package:budget_master/features/categories/application/category_providers.dart';
import 'package:budget_master/features/categories/application/category_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final Category? category;
  const AddEditCategoryScreen({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CategoryType _selectedCategoryType;

  bool get isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedCategoryType = isEditMode
        ? CategoryType.values[widget.category!.type]
        : CategoryType.expense;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatCategoryTypeName(CategoryType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final typeIndex = _selectedCategoryType.index;

      if (isEditMode) {
        final updatedCategory = widget.category!
          ..name = name
          ..type = typeIndex;
        ref.read(categoryServiceProvider).updateCategory(updatedCategory);
      } else {
        final newCategory = Category()
          ..name = name
          ..type = typeIndex;
        ref.read(categoryServiceProvider).addCategory(newCategory);
      }

      ref.read(categoriesProvider.notifier).state = ref
          .read(categoryServiceProvider)
          .getAllCategories();
      Navigator.of(context).pop();
    }
  }

  void _deleteCategory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the "${widget.category!.name}" category?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
            child: const Text('Delete'),
            onPressed: () {
              ref
                  .read(categoryServiceProvider)
                  .deleteCategory(widget.category!.id);
              ref.read(categoriesProvider.notifier).state = ref
                  .read(categoryServiceProvider)
                  .getAllCategories();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Category' : 'Add Category'),
        actions: [
          if (isEditMode)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: _deleteCategory,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Groceries, Salary, Transport',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<CategoryType>(
                initialValue: _selectedCategoryType,
                decoration: const InputDecoration(
                  labelText: 'Category Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: CategoryType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_formatCategoryTypeName(type)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategoryType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _saveCategory,
                icon: const Icon(Icons.save_alt_outlined),
                label: Text(isEditMode ? 'Save Changes' : 'Save Category'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

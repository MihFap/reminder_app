import 'package:flutter/material.dart';

class CategoryEditScreen extends StatefulWidget {
  const CategoryEditScreen({super.key});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  final List<String> _categories = ['Marketing', 'Shiloh'];

  void _addCategory() {
    setState(() {
      _categories.add('Danh mục mới');
    });
  }

  void _editCategory(int index) {
    setState(() {
      _categories[index] = '${_categories[index]} (đã sửa)';
    });
  }

  void _deleteCategory(int index) {
    setState(() {
      _categories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa danh mục')),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: Text(_categories[index]),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editCategory(index);
                  } else if (value == 'delete') {
                    _deleteCategory(index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xoá')),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}

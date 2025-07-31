import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config.dart';
import '../model/category_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;
  int? _userId;
  bool _dataChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchCategories();
  }

  Future<void> _loadUserIdAndFetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    if (_userId != null) {
      _fetchCategories();
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy người dùng.")),
        );
      }
    }
  }

  Future<void> _fetchCategories() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/Category/get?userId=$_userId");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _categories = data.map((json) => Category.fromJson(json)).toList();
          });
        }
      } else {
        throw Exception("Tải danh mục thất bại");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCategoryDialog({Category? categoryToEdit}) async {
    final TextEditingController controller =
    TextEditingController(text: categoryToEdit?.name);
    final isEditing = categoryToEdit != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Sửa danh mục" : "Thêm danh mục mới"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Tên danh mục"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                Navigator.of(context).pop();

                if (isEditing) {
                  await _updateCategory(categoryToEdit.id, name);
                } else {
                  await _createCategory(name);
                }
              },
              child: Text(isEditing ? "Lưu" : "Thêm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createCategory(String name) async {
    final uri = Uri.parse("${AppConfig.baseUrl}/Category/create");
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'userId': _userId}),
    );
    if (response.statusCode == 200) {
      _dataChanged = true; // ✅ ĐÁNH DẤU ĐÃ THAY ĐỔI
      _fetchCategories();
    } else {
      _showErrorSnackbar("Thêm mới thất bại");
    }
  }

  Future<void> _updateCategory(int id, String name) async {
    final uri = Uri.parse("${AppConfig.baseUrl}/Category/update?id=$id");
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'userId': _userId}),
    );
    if (response.statusCode == 200) {
      _dataChanged = true; // ✅ ĐÁNH DẤU ĐÃ THAY ĐỔI
      _fetchCategories();
    } else {
      _showErrorSnackbar("Cập nhật thất bại");
    }
  }

  Future<void> _deleteCategory(int id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa danh mục này không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: const Text("Hủy")),
          TextButton(
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uri = Uri.parse("${AppConfig.baseUrl}/Category/delete?id=$id");
              final response = await http.delete(uri);
              if (response.statusCode == 200) {
                _dataChanged = true; // ✅ ĐÁNH DẤU ĐÃ THAY ĐỔI
                _fetchCategories();
              } else {
                _showErrorSnackbar("Xóa thất bại");
              }
            },
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(_dataChanged);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ListTile(
              leading: const Icon(Icons.folder_open_outlined, color: Colors.green),
              title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showCategoryDialog(categoryToEdit: category);
                  } else if (value == 'delete') {
                    _deleteCategory(category.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 8), Text('Sửa')])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xoá')])),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'category_edit_screen.dart'; // 🟩 Gắn giao diện chỉnh sửa

class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý danh mục')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryItem("Marketing"),
          _buildCategoryItem("Shiloh"),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            print("Đã bấm Thêm danh mục");
            // ⏩ Chuyển sang màn hình chỉnh sửa danh mục
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryEditScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Thêm danh mục"),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.folder),
        title: Text(title),
        trailing: const Icon(Icons.visibility),
      ),
    );
  }
}

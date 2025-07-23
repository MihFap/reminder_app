import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_note_screen.dart';

class NoteCreateScreen extends StatefulWidget {
  final List<String> categories;
  final List<Note> existingNotes;
  final String selectedCategory;

  const NoteCreateScreen({
    super.key,
    required this.categories,
    required this.existingNotes,
    this.selectedCategory = 'Tất cả',
  });

  @override
  State<NoteCreateScreen> createState() => _NoteCreateScreenState();
}

class _NoteCreateScreenState extends State<NoteCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();

  late List<String> categories;
  late String selectedCategory;

  final List<String> specialCategories = ['Tất cả', 'Yêu thích'];

  @override
  void initState() {
    super.initState();
    categories = widget.categories.toSet().toList();
    selectedCategory = widget.selectedCategory;

    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }
  }

  void saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final isDuplicate = widget.existingNotes.any((note) => note.title == title);
    if (isDuplicate) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Tiêu đề trùng"),
          content: const Text("Tiêu đề này đã tồn tại. Vui lòng đặt tiêu đề khác."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final newNote = Note(
      title: title,
      content: content,
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      category: selectedCategory,
    );

    Navigator.pop(context, newNote);
  }

  void showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm danh mục mới"),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(hintText: "Tên danh mục"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final newCategory = _newCategoryController.text.trim();

              if (newCategory.isNotEmpty &&
                  !categories.contains(newCategory) &&
                  !specialCategories.contains(newCategory)) {
                setState(() {
                  categories.add(newCategory);
                  selectedCategory = newCategory;
                });
              }

              _newCategoryController.clear();
              Navigator.pop(context);
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffef4ff),
      appBar: AppBar(
        backgroundColor: const Color(0xfffef4ff),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Ghi chú",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: saveNote,
            child: const Text("Lưu", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Tiêu đề",
                    ),
                  ),
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Nội dung",
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        "Chọn danh mục",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

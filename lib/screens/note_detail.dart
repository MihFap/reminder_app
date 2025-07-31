import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../app_config.dart';
import '../model/category_model.dart';
import '../model/note_model.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? noteToEdit; // Nếu null -> Tạo mới. Nếu có -> Sửa
  final int userId;
  final List<Category> categories;

  const NoteDetailScreen({
    super.key,
    this.noteToEdit,
    required this.userId,
    required this.categories,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  int? _selectedCategoryId;
  bool _isSaving = false;

  bool get _isEditMode => widget.noteToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteToEdit?.title ?? '');
    _contentController = TextEditingController(text: widget.noteToEdit?.content ?? '');

    if (_isEditMode) {
      _selectedCategoryId = widget.noteToEdit!.categoryId;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn một danh mục.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final url = _isEditMode
          ? "${AppConfig.baseUrl}/Note/update?id=${widget.noteToEdit!.id}"
          : "${AppConfig.baseUrl}/Note/create";

      final uri = Uri.parse(url);

      final body = jsonEncode({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
        'userId': widget.userId,
        'categoryId': _selectedCategoryId,
        'isFavorite': _isEditMode ? widget.noteToEdit!.isFavorite : false,
      });

      final response = _isEditMode
          ? await http.put(uri, headers: {'Content-Type': 'application/json'}, body: body)
          : await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode ? "Cập nhật thành công!" : "Tạo ghi chú thành công!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Lỗi từ server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã xảy ra lỗi: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Trong file note_detail.dart, thay thế toàn bộ hàm build bằng đoạn code này

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Hàng trên cùng chỉ có nút Lưu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: _isSaving ? null : _saveNote,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Lưu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        // ✅ ĐẶT DROPDOWN VÀO KHU VỰC RIÊNG BIỆT BÊN DƯỚI
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // Chiều cao của khu vực chứa dropdown
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0.0),
            child: Align(
              // Đẩy dropdown về phía bên phải
              alignment: Alignment.centerRight,
              child: (widget.categories.isNotEmpty)
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    items: widget.categories
                        .map((category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategoryId = value);
                      }
                    },
                  ),
                ),
              )
                  : const SizedBox.shrink(), // Ẩn đi nếu không có danh mục
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16), // Thêm khoảng cách với AppBar
              // Trường nhập tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                maxLines: null,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề.';
                  }
                  return null;
                },
              ),

              // Trường nhập chi tiết
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Chi tiết',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 18),
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
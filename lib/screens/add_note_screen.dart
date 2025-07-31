import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
import '../model/note_model.dart';
import '../model/category_model.dart';
import 'note_detail.dart';
import 'category_screen.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => AddNoteScreenState();
}

class AddNoteScreenState extends State<AddNoteScreen> {
  bool _isLoading = true;
  int? _userId;

  List<Category> _categories = [];
  List<Note> _notes = [];
  String _selectedFilter = "Tất cả"; // Có thể là "Tất cả", "Yêu thích", hoặc tên danh mục

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() { _isLoading = true; });
    await _loadUserId();
    if (_userId != null) {
      await fetchCategoriesAndNotes();
    } else {
      // Xử lý trường hợp không tìm thấy userId (ví dụ: yêu cầu đăng nhập)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy người dùng. Vui lòng đăng nhập lại.")),
        );
      }
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // ⚠️ Để test, bạn có thể gán cứng userId. Trong ứng dụng thực tế, userId sẽ được lưu sau khi đăng nhập.
    // await prefs.setInt('userId', 1);
    _userId = prefs.getInt('userId');
  }

  Future<void> fetchCategoriesAndNotes() async {
    if (_userId == null) return;
    try {
      // Tải và giải mã danh mục MỘT LẦN
      final catUri = Uri.parse("${AppConfig.baseUrl}/Category/get?userId=$_userId");
      final catResponse = await http.get(catUri);
      if (catResponse.statusCode != 200) throw Exception('Failed to load categories');
      final List<dynamic> catJsonList = jsonDecode(catResponse.body);

      if (mounted) {
        setState(() {
          _categories = catJsonList.map((json) => Category.fromJson(json)).toList();
        });
      }

      // Tải ghi chú và TÁI SỬ DỤNG catJsonList
      final noteUri = Uri.parse("${AppConfig.baseUrl}/Note/get?userId=$_userId");
      final noteResponse = await http.get(noteUri);
      if (noteResponse.statusCode != 200) throw Exception('Failed to load notes');
      final List<dynamic> noteData = jsonDecode(noteResponse.body);

      if (mounted) {
        setState(() {
          _notes = noteData.map((json) => Note.fromJson(json, catJsonList)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải dữ liệu: ${e.toString()}")),
        );
      }
    }
  }

  List<Note> get filteredNotes {
    if (_selectedFilter == "Tất cả") return _notes;
    if (_selectedFilter == "Yêu thích") return _notes.where((n) => n.isFavorite).toList();
    return _notes.where((n) => n.categoryName == _selectedFilter).toList();
  }

  // --- CÁC HÀM CRUD ---

  Future<void> _toggleFavorite(Note note) async {
    final originalStatus = note.isFavorite;
    setState(() {
      note.isFavorite = !originalStatus;
    });

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/Note/updateFavorite/${note.id}");
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note.isFavorite),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update favorite status");
      }
    } catch (e) {
      // Hoàn tác nếu có lỗi
      setState(() {
        note.isFavorite = originalStatus;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi cập nhật Yêu thích: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _deleteNote(int noteId) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/Note/delete?id=$noteId");
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        setState(() {
          _notes.removeWhere((note) => note.id == noteId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Xóa ghi chú thành công"), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception("Failed to delete note");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi xóa ghi chú: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmation(Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa ghi chú '${note.title}' không?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteNote(note.id);
            },
          ),
        ],
      ),
    );
  }

  // --- CÁC HÀM ĐIỀU HƯỚNG ---
  void _navigateToAddNote() async {
    if (_userId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(
        userId: _userId!,
        categories: _categories,
        // noteToEdit là null vì đây là chế độ tạo mới
      )),
    );

    if (result == true) {
      fetchCategoriesAndNotes();
    }
  }

  void _navigateToEditNote(Note note) async {
    if (_userId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(
        userId: _userId!,
        categories: _categories,
        noteToEdit: note, // Truyền note hiện tại vào để sửa
      )),
    );

    if (result == true) {
      fetchCategoriesAndNotes();
    }
  }

  void _navigateToEditCategories() async {
    // Dùng `await` để chờ màn hình quản lý danh mục đóng lại
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryScreen(),
      ),
    );

    // Nếu kết quả trả về là `true` (có thay đổi), thì tải lại dữ liệu
    if (result == true) {
      fetchCategoriesAndNotes();
    }
  }


  @override
  Widget build(BuildContext context) {
    final List<String> filterTabs = ["Tất cả", "Yêu thích", ..._categories.map((c) => c.name)];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ghi chú", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filterTabs.map((categoryName) {
                        final isSelected = categoryName == _selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(categoryName),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedFilter = categoryName),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  tooltip: "Thêm/Sửa danh mục",
                  // ✅ ĐẢM BẢO DÒNG NÀY ĐÚNG
                  onPressed: _navigateToEditCategories,
                ),
              ],
            ),
          ),
          // GridView
          Expanded(
            child: filteredNotes.isEmpty
                ? const Center(child: Text("Không có ghi chú nào."))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredNotes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              // Trong file add_note_screen.dart -> hàm build -> GridView.builder

              // Trong file add_note_screen.dart -> hàm build -> GridView.builder

              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return Card(
                  clipBehavior: Clip.antiAlias, // Giúp hiệu ứng nhấn đẹp hơn ở các góc bo tròn
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell( // Bọc Card bằng InkWell để có thể nhấn vào
                    onTap: () {
                      // Gọi hàm sửa ghi chú khi nhấn vào thẻ
                      _navigateToEditNote(note);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  note.title.isEmpty ? "(Không tiêu đề)" : note.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Gọi trực tiếp hàm toggle favorite
                                  _toggleFavorite(note);
                                },
                                child: Icon(
                                  note.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: note.isFavorite ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              note.content,
                              style: TextStyle(color: Colors.grey.shade600),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  note.formattedDate,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)
                              ),
                              // THAY THẾ NÚT 3 CHẤM BẰNG ICON THÙNG RÁC
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                onPressed: () {
                                  // Gọi hàm xác nhận xóa khi nhấn vào
                                  _showDeleteConfirmation(note);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNote,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
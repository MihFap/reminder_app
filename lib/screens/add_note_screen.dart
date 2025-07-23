import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note_create_screen.dart';
import 'category_edit_screen.dart';

class Note {
  final String title;
  final String content;
  final String date;
  final String category;
  bool isFavorite;

  Note({
    required this.title,
    required this.content,
    required this.date,
    required this.category,
    this.isFavorite = false,
  });
}



class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final List<String> categories = ["Tất cả", "Marketing"];
  String selectedCategory = "Tất cả";

  final List<Note> notes = [
    Note(title: "dhjijd", content: "dsujkkdkd", date: "24/07/2025", category: "Tất cả"),
    Note(title: "vhjkcwvh", content: "", date: "24/07/2025", category: "Tất cả", isFavorite: true),
    Note(title: "Là cafe", content: "", date: "24/07/2025", category: "Tất cả"),
    Note(title: "shsjdjsbdb", content: "jfdfkdskle", date: "24/07/2025", category: "Tất cả"),
    Note(title: "note 1", content: "hdjdk", date: "24/07/2025", category: "Tất cả", isFavorite: true),
    Note(title: "ghi chú marketing", content: "chạy quảng cáo", date: "24/07/2025", category: "Marketing", isFavorite: false),
  ];


  List<Note> get filteredNotes {
    if (selectedCategory == "Tất cả") return notes;
    if (selectedCategory == "Yêu thích") return notes.where((n) => n.isFavorite).toList();
    return notes.where((n) => n.category == selectedCategory).toList();
  }

  void _addCategory() async {
    final newCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        String newName = "";
        return AlertDialog(
          title: const Text("Thêm danh mục mới"),
          content: TextField(
            autofocus: true,
            onChanged: (value) => newName = value,
            decoration: const InputDecoration(hintText: "Tên danh mục"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                if (newName.isNotEmpty && !categories.contains(newName) && newName != "Yêu thích") {
                  Navigator.pop(context, newName);
                }
              },
              child: const Text("Thêm"),
            ),
          ],
        );
      },
    );

    if (newCategory != null) {
      setState(() {
        categories.add(newCategory);
        selectedCategory = newCategory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> filterTabs = ["Tất cả", "Yêu thích", ...categories.where((e) => e != "Tất cả")];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ghi chú", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filterTabs.map((category) {
                        final isSelected = category == selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  tooltip: "Thêm danh mục",
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
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredNotes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
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
                              setState(() {
                                note.isFavorite = !note.isFavorite;
                              });
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
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(note.date, style: const TextStyle(fontSize: 12)),
                          const Icon(Icons.more_horiz, size: 20),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push<Note>(
            context,
            MaterialPageRoute(
              builder: (_) => NoteCreateScreen(
                selectedCategory: selectedCategory,
                categories: categories,
                existingNotes: notes,
              ),
            ),
          );
          if (newNote != null) {
            setState(() {
              notes.add(newNote);
            });
          }
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

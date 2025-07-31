import 'package:intl/intl.dart';

class Note {
  final int id;
  String title;
  String content;
  DateTime createdAt;
  bool isFavorite; // ⚠️ Xem ghi chú ở cuối
  int userId;
  int categoryId;
  String categoryName; // Thêm để hiển thị

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isFavorite = false,
    required this.userId,
    required this.categoryId,
    this.categoryName = '',
  });

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  factory Note.fromJson(Map<String, dynamic> json, List<dynamic> categoriesJson) {
    // Tìm tên category từ categoryId
    final category = categoriesJson.firstWhere(
          (cat) => cat['id'] == json['categoryId'],
      orElse: () => {'name': 'Không xác định'},
    );

    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'] ?? false, // ⚠️ Xem ghi chú ở cuối
      userId: json['userId'],
      categoryId: json['categoryId'],
      categoryName: category['name'],
    );
  }
}
import 'dart:convert';

class Todo {
  final int id;
  String title;
  String? description;
  final DateTime startTime;
  final DateTime endTime;
  bool isCompleted;
  final int userId;
  final DateTime remindAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
    required this.userId,
    required this.remindAt,
  });

  // Hàm này dùng để chuyển đổi dữ liệu JSON từ server thành đối tượng Todo
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isCompleted: json['isCompleted'],
      userId: json['userId'],
      remindAt: DateTime.parse(json['remindAt']),
    );
  }

  // Hàm này dùng để chuyển đối tượng Todo thành JSON (hữu ích khi gửi dữ liệu lên server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isCompleted': isCompleted,
      'userId': userId,
      'remindAt': remindAt.toIso8601String(),
    };
  }
}
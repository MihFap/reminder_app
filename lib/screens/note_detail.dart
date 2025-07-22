import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy màu chữ phụ từ theme hiện tại
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    final String currentTime =
    DateFormat('dd MMMM, HH:mm', 'vi_VN').format(DateTime.now());

    return Scaffold(
      // XÓA: backgroundColor: Colors.white
      appBar: AppBar(
        // XÓA: backgroundColor và elevation
        // Icon và chữ sẽ tự động đổi màu theo theme
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: () {
                // Logic lưu ghi chú
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Lưu'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ngày giờ hiện tại
            Text(
              currentTime,
              // SỬA: Dùng màu từ theme
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Tiêu đề',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              cursorColor: Colors.green,
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Nhập thêm vào đây...',
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                cursorColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
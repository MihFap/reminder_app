import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TodoDetailScreen extends StatefulWidget {
  const TodoDetailScreen({super.key});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  // 1. Thêm các Controller để lấy dữ liệu
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController(); // Controller cho miêu tả

  bool _isAllDay = false;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    // Quan trọng: Hủy controller
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 4. Cập nhật hàm gọi API để lấy dữ liệu động
  void _saveTodo() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.isEmpty) {
      // Hiển thị thông báo nếu tiêu đề trống
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề cho nhiệm vụ.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("http://172.16.7.146:5056/Todo/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9lbWFpbGFkZHJlc3MiOiJhZG1pbkBnbWFpbC5jb20iLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiVGVzdFVzZXIiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjEiLCJleHAiOjE3NTMyMjIyMDUsImlzcyI6InJlbWluZGVyIiwiYXVkIjoicmVtaW5kZXItdXNlciJ9.tB5_jA8seIkDswvdTYsTxYJ0ljuqELCSzL4i5YgAJtw",
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "startTime": _startTime.toIso8601String(), // Chuyển sang định dạng chuỗi ISO
        "endTime": _endTime.toIso8601String()
      }),
    );

    if (response.statusCode == 200 && mounted) {
      print("✅ Tạo thành công: ${response.body}");
      Navigator.of(context).pop();
    } else {
      print("❌ Lỗi: ${response.statusCode} - ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _saveTodo, // 3. Gọi hàm _saveTodo khi nhấn Lưu
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Lưu'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 2. Gán controller cho các TextField
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Thêm tiêu đề',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 22),
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildTimeSection(),
          const Divider(),
          _buildReminderSection(),
          const Divider(),
          _buildOptionRow(
            icon: Icons.repeat,
            title: 'Lặp lại',
            subtitle: 'Không có',
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(),
          // Sử dụng TextField thay vì _buildOptionRow cho phần miêu tả
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              icon: Icon(Icons.description_outlined),
              hintText: 'Thêm miêu tả',
              border: InputBorder.none,
            ),
            maxLines: null, // Cho phép nhập nhiều dòng
          ),
        ],
      ),
    );
  }

  // Các hàm build khác giữ nguyên như trước...
  Widget _buildTimeSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.access_time),
            const SizedBox(width: 16),
            const Text('Cả ngày'),
            const Spacer(),
            Switch(value: _isAllDay, onChanged: (value) => setState(() => _isAllDay = value)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.watch_later_outlined),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _showCustomTimePicker(context, true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('E, d MMM', 'vi_VN').format(_startTime), style: const TextStyle(fontSize: 12)),
                  Text(DateFormat('HH:mm').format(_startTime), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Spacer(),
            const Text('/'),
            const Spacer(),
            GestureDetector(
              onTap: () => _showCustomTimePicker(context, false),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat('E, d MMM', 'vi_VN').format(_endTime), style: const TextStyle(fontSize: 12)),
                  Text(DateFormat('HH:mm').format(_endTime), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomTimePicker(BuildContext context, bool isStartTime) {
    DateTime initialTime = isStartTime ? _startTime : _endTime;
    int selectedHour = initialTime.hour;
    int selectedMinute = initialTime.minute;

    final hourController = FixedExtentScrollController(initialItem: selectedHour);
    final minuteController = FixedExtentScrollController(initialItem: selectedMinute);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [Text('Cài đặt thời gian'), Spacer(), Icon(Icons.watch_later_outlined)],
          ),
          content: SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 70,
                  child: ListWheelScrollView.useDelegate(
                    controller: hourController, itemExtent: 50, perspective: 0.005, diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) => selectedHour = index,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 24,
                      builder: (context, index) => Center(child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 22))),
                    ),
                  ),
                ),
                const Text(':', style: TextStyle(fontSize: 24)),
                SizedBox(
                  width: 70,
                  child: ListWheelScrollView.useDelegate(
                    controller: minuteController, itemExtent: 50, perspective: 0.005, diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) => selectedMinute = index,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 60,
                      builder: (context, index) => Center(child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 22))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
            TextButton(
              onPressed: () {
                setState(() {
                  final now = DateTime.now();
                  final newTime = DateTime(now.year, now.month, now.day, selectedHour, selectedMinute);
                  if (isStartTime) {
                    _startTime = newTime;
                    if (_endTime.isBefore(_startTime.add(const Duration(hours: 1)))) {
                      _endTime = _startTime.add(const Duration(hours: 1));
                    }
                  } else {
                    _endTime = newTime;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReminderSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.notifications_outlined),
            const SizedBox(width: 16),
            const Text('Lời nhắc'),
            const Spacer(),
            Text('Thêm >', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Text('15 phút trước'),
              const Spacer(),
              Icon(Icons.close, size: 16, color: Theme.of(context).iconTheme.color),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 16),
            const SizedBox(width: 8),
            const Text('Lời nhắc không hoạt động. Vui lòng cấp quyền thông báo', style: TextStyle(fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}
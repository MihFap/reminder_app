import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoDetailScreen extends StatefulWidget {
  const TodoDetailScreen({super.key});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  bool _isAllDay = false;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));



    }
    } else {
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
              hintText: 'Thêm tiêu đề',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 22),
            ),
          ),
          const Divider(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            const Text('Cả ngày'),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
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

  Widget _buildReminderSection() {
    return Column(
      children: [
        Row(
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('15 phút trước'),
              const Spacer(),
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
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}
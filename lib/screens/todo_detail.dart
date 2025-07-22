import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoDetailScreen extends StatefulWidget {
  const TodoDetailScreen({super.key});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  bool _isAllDay = false;

  // 1. Thêm State để quản lý thời gian động
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

  // 2. Thêm lại hàm hiển thị Dialog chọn giờ
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
            children: const [
              Text('Cài đặt thời gian'),
              Spacer(),
              Icon(Icons.watch_later_outlined)
            ],
          ),
          content: SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 70,
                  child: ListWheelScrollView.useDelegate(
                    controller: hourController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) => selectedHour = index,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 24,
                      builder: (context, index) => Center(
                        child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                ),
                const Text(':', style: TextStyle(fontSize: 24)),
                SizedBox(
                  width: 70,
                  child: ListWheelScrollView.useDelegate(
                    controller: minuteController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) => selectedMinute = index,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 60,
                      builder: (context, index) => Center(
                        child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 22)),
                      ),
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
                    if(_endTime.isBefore(_startTime.add(const Duration(hours: 1)))){
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // XÓA: backgroundColor: Colors.white
      appBar: AppBar(
        // XÓA: backgroundColor và elevation
        // Icon và chữ sẽ tự động đổi màu theo theme
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: () {},
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
          const TextField(
            decoration: InputDecoration(
              hintText: 'Thêm tiêu đề',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 22),
            ),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildTimeSection(), // 3. Gọi hàm đã được cập nhật
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
          _buildOptionRow(
            icon: Icons.description_outlined,
            title: 'Miêu tả',
            trailing: const Text('Thêm >', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // 3. Cập nhật Widget cho phần chọn thời gian
  Widget _buildTimeSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey),
            const SizedBox(width: 16),
            const Text('Cả ngày'),
            const Spacer(),
            Switch(
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.watch_later_outlined, color: Colors.grey),
            const SizedBox(width: 16),
            // Ô giờ bắt đầu (có thể nhấn)
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
            // Ô giờ kết thúc (có thể nhấn)
            GestureDetector(
              onTap: () => _showCustomTimePicker(context, false),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
    // Giữ nguyên mã của bạn
    return Column(
      children: [
        Row(
          children: const [
            Icon(Icons.notifications_outlined, color: Colors.grey),
            SizedBox(width: 16),
            Text('Lời nhắc'),
            Spacer(),
            Text('Thêm >', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.lightGreen, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Text('15 phút trước'),
              const Spacer(),
              Icon(Icons.close, size: 16, color: Colors.grey.shade600),
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
    // Giữ nguyên mã của bạn, đã bỏ isPro
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}
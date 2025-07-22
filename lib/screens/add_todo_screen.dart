import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // XÓA: backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildWeekSelector(),
          _buildEmptyState(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    // AppBar sẽ tự nhận màu từ Theme
    return AppBar(
      // XÓA: backgroundColor và elevation
      // title và actions sẽ tự nhận màu chữ/icon phù hợp
      title: const Text('Nhiệm vụ'),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildWeekSelector() {
    DateTime startOfWeek = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    List<DateTime> daysInWeek = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    // Lấy màu chữ mặc định từ theme
    final defaultTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _focusedDate = _focusedDate.subtract(const Duration(days: 7));
                    });
                  },
                ),
                Text(
                  '${DateFormat('d MMM', 'vi_VN').format(startOfWeek)} - ${DateFormat('d MMM', 'vi_VN').format(endOfWeek)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _focusedDate = _focusedDate.add(const Duration(days: 7));
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: daysInWeek.map((day) {
              final bool isSelected = DateUtils.isSameDay(day, _selectedDay);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      DateFormat.E('vi_VN').format(day),
                      style: TextStyle(
                          color: secondaryTextColor, // Dùng màu từ theme
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // Màu xanh cho ngày được chọn vẫn giữ lại
                        color: isSelected ? Colors.green : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        DateFormat.d().format(day),
                        style: TextStyle(
                          // Chữ trắng khi được chọn, còn lại theo màu theme
                          color: isSelected ? Colors.white : defaultTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Expanded(
      child: Center(
        child: Text(
          'Ngày này chưa có ghi chú',
          style: TextStyle(fontSize: 18), // Xóa màu cố định
        ),
      ),
    );
  }
}
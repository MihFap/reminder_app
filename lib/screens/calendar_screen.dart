import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Lưu trữ ngày tháng đang được hiển thị
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now(); // Ngày được chọn

  // Hàm thay đổi tháng khi người dùng nhấn vào mũi tên
  void _onMonthChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  // Hàm thay đổi tháng và năm
  void _changeMonth(int delta) {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh điều hướng tháng và năm
        Padding(
          padding: const EdgeInsets.only(top: 50, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left, color: Colors.green),
                onPressed: () => _changeMonth(-1), // Chuyển sang tháng trước
              ),
              SizedBox(width: 10),
              Text(
                "${_focusedDay.month}/${_focusedDay.year}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.arrow_right, color: Colors.green),
                onPressed: () => _changeMonth(1), // Chuyển sang tháng sau
              ),
            ],
          ),
        ),
        // Tabs Tháng | Danh sách | Tuần | Ngày

        Expanded(
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay, // Cập nhật ngày hiện tại
            selectedDayPredicate: (day) {
              // Kiểm tra ngày đã được chọn chưa
              return isSameDay(day, _selectedDay);
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerVisible: false,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Cập nhật ngày khi người dùng chọn ngày mới
              });
            },
            onPageChanged: (focusedDay) {
              _onMonthChanged(focusedDay); // Khi người dùng chuyển đổi tháng
            },
            // Thay đổi kích thước của lịch
            rowHeight: 75.0, // Thay đổi chiều cao mỗi ô ngày
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(fontSize: 30.0), // Kích thước chữ tiêu đề
              formatButtonVisible: false, // Ẩn nút chuyển tháng
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 15.0), // Kích thước chữ của ngày trong tuần
              weekendStyle: TextStyle(fontSize: 15.0, color: Colors.red), // Ngày cuối tuần
            ),
          ),
        ),
      ],
    );
  }
}

class CalendarTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CalendarTabButton({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.green : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

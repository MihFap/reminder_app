import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh điều hướng tháng
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, color: Colors.green),
              SizedBox(width: 10),
              Text(
                "THÁNG 7",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Icon(Icons.play_arrow, color: Colors.black),
            ],
          ),
        ),
        // Tabs Tháng | Danh sách | Tuần | Ngày
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CalendarTabButton(label: "Tháng", isSelected: true),
            CalendarTabButton(label: "Danh sách"),
            CalendarTabButton(label: "Tuần"),
            CalendarTabButton(label: "Ngày"),
          ],
        ),
        // Table Calendar
        Expanded(
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
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

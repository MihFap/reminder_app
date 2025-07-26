import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/todo_model.dart'; // Đảm bảo đường dẫn này đúng
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int? _userId;
  Map<DateTime, List<Todo>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    if (_userId != null) {
      try {
        final todos = await fetchTodos(_userId!);
        setState(() {
          _events = groupTodosByDate(todos);
        });
      } catch (e) {
        // Xử lý lỗi nếu không fetch được
        print('Error fetching todos: $e');
      }
    }
  }

  Future<List<Todo>> fetchTodos(int userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.13:5056/Todo/get?userId=$userId'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      // Chuyển đổi DateTime sang giờ địa phương ngay tại đây
      return jsonData.map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // SỬA LẠI LOGIC NHÓM CÔNG VIỆC CHO ĐÚNG
  Map<DateTime, List<Todo>> groupTodosByDate(List<Todo> todos) {
    Map<DateTime, List<Todo>> events = {};

    for (var todo in todos) {
      // Chỉ lấy phần ngày, bỏ qua phần giờ để so sánh chính xác
      final startDate = DateTime.utc(todo.startTime.year, todo.startTime.month, todo.startTime.day);
      final endDate = DateTime.utc(todo.endTime.year, todo.endTime.month, todo.endTime.day);

      // Lặp từ ngày bắt đầu đến ngày kết thúc (bao gồm cả hai)
      for (var day = startDate; !day.isAfter(endDate); day = day.add(const Duration(days: 1))) {
        // Key của Map events là một ngày đã được chuẩn hóa (không có giờ)
        final dateOnly = DateTime(day.year, day.month, day.day);
        events.putIfAbsent(dateOnly, () => []).add(todo);
      }
    }
    return events;
  }

  // Hàm trợ giúp để lấy định dạng thứ tùy chỉnh
  String _getVietnameseDow(DateTime date) {
    String weekday = DateFormat('EEEE', 'vi_VN').format(date);
    switch (weekday) {
      case 'Thứ Hai': return 'TH 2';
      case 'Thứ Ba': return 'TH 3';
      case 'Thứ Tư': return 'TH 4';
      case 'Thứ Năm': return 'TH 5';
      case 'Thứ Sáu': return 'TH 6';
      case 'Thứ Bảy': return 'TH 7';
      case 'Chủ Nhật': return 'CN';
      default: return '';
    }
  }

  // ⭐️ HÀM MỚI: Widget để vẽ một công việc bên trong ô lịch
  // ⭐️ HÀM MỚI ĐÃ SỬA LỖI GIAO DIỆN
  Widget _buildEventItem(Todo todo, DateTime forDay) {
    final dayOfEvent = DateTime.utc(forDay.year, forDay.month, forDay.day);
    final todoStartDate = DateTime.utc(todo.startTime.year, todo.startTime.month, todo.startTime.day);
    final todoEndDate = DateTime.utc(todo.endTime.year, todo.endTime.month, todo.endTime.day);

    final bool isStart = isSameDay(dayOfEvent, todoStartDate);
    final bool isEnd = isSameDay(dayOfEvent, todoEndDate);
    final bool isSingleDay = isSameDay(todoStartDate, todoEndDate);

    // Tùy chỉnh bo tròn góc để tạo hiệu ứng kéo dài
    BorderRadius borderRadius;
    if (isSingleDay) {
      // Công việc trong 1 ngày: bo tròn 4 góc
      borderRadius = BorderRadius.circular(6.0);
    } else if (isStart) {
      // Ngày bắt đầu của chuỗi: chỉ bo tròn 2 góc bên trái
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(6.0),
        bottomLeft: Radius.circular(6.0),
      );
    } else if (isEnd) {
      // Ngày kết thúc của chuỗi: chỉ bo tròn 2 góc bên phải
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(6.0),
        bottomRight: Radius.circular(6.0),
      );
    } else {
      // Phần giữa của chuỗi: không bo tròn góc nào
      borderRadius = BorderRadius.zero;
    }

    return Container(
      // Bỏ margin ngang, chỉ giữ margin dọc để các thanh liền nhau
      margin: const EdgeInsets.symmetric(vertical: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 15,
      decoration: BoxDecoration(
        color: Colors.teal.shade300,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              todo.title,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch Tháng")),
      // Bọc trong SingleChildScrollView để tránh lỗi tràn màn hình nếu ô quá cao
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar<Todo>(
              locale: 'vi_VN',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              // ⭐️ THAY ĐỔI QUAN TRỌNG: Tăng chiều cao các ô
              rowHeight: 120, // Chiều cao mỗi ô
              daysOfWeekHeight: 25, // Chiều cao hàng tiêu đề thứ

              eventLoader: (day) {
                // Key để lấy event phải được chuẩn hóa
                return _events[DateTime(day.year, day.month, day.day)] ?? [];
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },

              // ⭐️ TÙY CHỈNH GIAO DIỆN NÂNG CAO
              calendarBuilders: CalendarBuilders(
                // Tiêu đề các thứ (TH 2, TH 3, ...)
                dowBuilder: (context, day) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.green[100]),
                    alignment: Alignment.center,
                    child: Text(
                      _getVietnameseDow(day),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
                    ),
                  );
                },
                // Builder chính để vẽ các ô ngày
                defaultBuilder: (context, day, focusedDay) {
                  final eventsForDay = _events[DateTime(day.year, day.month, day.day)] ?? [];
                  // ⭐️ Giới hạn số công việc hiển thị, ví dụ là 4
                  const int maxEventsToShow = 4;

                  // Lấy danh sách con để hiển thị
                  final eventsToShow = eventsForDay.take(maxEventsToShow).toList();
                  // Kiểm tra xem có còn công việc nào bị ẩn không
                  final bool hasMoreEvents = eventsForDay.length > maxEventsToShow;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber.shade300, width: 0.5),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${day.day}'), // Hiển thị ngày
                        const SizedBox(height: 2),

                        // --- BẮT ĐẦU THAY ĐỔI ---
                        // Chỉ hiển thị các công việc trong danh sách đã giới hạn
                        ...eventsToShow.map((event) => _buildEventItem(event, day)),

                        // Nếu có công việc bị ẩn, hiển thị dấu "..."
                        if (hasMoreEvents)
                          const Center(
                            child: Text(
                              '...',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ),
                        // --- KẾT THÚC THAY ĐỔI ---
                      ],
                    ),
                  );
                },
                // Lặp lại logic cho các builder khác để giao diện đồng nhất
                todayBuilder: (context, day, focusedDay) {
                  final eventsForDay = _events[DateTime(day.year, day.month, day.day)] ?? [];
                  const int maxEventsToShow = 4;
                  final eventsToShow = eventsForDay.take(maxEventsToShow).toList();
                  final bool hasMoreEvents = eventsForDay.length > maxEventsToShow;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2), // highlight ngày hôm nay
                      border: Border.all(color: Colors.amber.shade300, width: 0.5),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        ...eventsToShow.map((event) => _buildEventItem(event, day)),
                        if (hasMoreEvents)
                          const Center(
                            child: Text(
                              '...',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final eventsForDay = _events[DateTime(day.year, day.month, day.day)] ?? [];
                  const int maxEventsToShow = 4;
                  final eventsToShow = eventsForDay.take(maxEventsToShow).toList();
                  final bool hasMoreEvents = eventsForDay.length > maxEventsToShow;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3), // highlight ngày được chọn
                      border: Border.all(color: Colors.blue.shade300, width: 1.0),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                        ),
                        const SizedBox(height: 2),
                        ...eventsToShow.map((event) => _buildEventItem(event, day)),
                        if (hasMoreEvents)
                          Center(
                            child: Text(
                              '...',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                outsideBuilder: (context, day, focusedDay) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber.shade300, width: 0.5),
                    ),
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  // Trả về một widget trống để ẩn hoàn toàn các dấu mặc định
                  return const SizedBox.shrink();
                },
              ),
            ),
            // ĐÃ XÓA PHẦN LISTVIEW HIỂN THỊ TODO Ở DƯỚI
          ],
        ),
      ),
    );
  }
}
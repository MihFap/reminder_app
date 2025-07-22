// add_todo_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reminder_app/model/todo_model.dart'; // Kiểm tra lại đường dẫn này

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  int? _userId;

  List<Todo> _allTodosForUser = [];
  List<Todo> _todosForSelectedDay = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchTodos();
  }

  void _loadUserIdAndFetchTodos() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    if (_userId != null) {
      _fetchTodos();
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy người dùng. Vui lòng đăng nhập lại.')),
        );
      }
    }
  }

  Future<void> _fetchTodos() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('http://172.16.7.146:5056/Todo/get?userId=$_userId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _allTodosForUser = data.map((json) => Todo.fromJson(json)).toList();
        _filterTodosForSelectedDay();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải dữ liệu: ${response.reasonPhrase}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterTodosForSelectedDay() {
    _todosForSelectedDay = _allTodosForUser.where((todo) {
      return DateUtils.isSameDay(todo.startTime, _selectedDay);
    }).toList();
    _todosForSelectedDay.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
  }

  // HÀM ĐÃ ĐƯỢC CẬP NHẬT THEO HTTP PATCH
  Future<void> _toggleTodoStatus(Todo todo) async {
    final newStatus = !todo.isCompleted;

    setState(() {
      todo.isCompleted = newStatus;
      _filterTodosForSelectedDay();
    });

    final patchDoc = [
      {
        'op': 'replace',
        'path': '/isCompleted',
        'value': newStatus,
      }
    ];

    try {
      final uri = Uri.parse("http://172.16.7.146:5056/Todo/update/${todo.id}");

      final response = await http.patch(
        uri,
        headers: {
          "Content-Type": "application/json-patch+json",
        },
        body: jsonEncode(patchDoc),
      );

      if (response.statusCode != 200) {
        print('API Error - Status Code: ${response.statusCode}');
        print('API Error - Body: ${response.body}');

        setState(() {
          todo.isCompleted = !newStatus;
          _filterTodosForSelectedDay();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại.')),
          );
        }
      }
    } catch (e) {
      setState(() {
        todo.isCompleted = !newStatus;
        _filterTodosForSelectedDay();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối khi cập nhật: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildWeekSelector(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todosForSelectedDay.isEmpty
                ? _buildEmptyState()
                : _buildTodoList(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    DateTime startOfWeek = _focusedDate.subtract(Duration(days: _focusedDate.weekday % 7));
    if (DateFormat.E('en_US').format(startOfWeek) != 'Sun') {
      startOfWeek = startOfWeek.subtract(Duration(days: startOfWeek.weekday));
    }
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    List<DateTime> daysInWeek = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    final defaultTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                  'Tháng ${DateFormat('M, yyyy', 'vi_VN').format(_focusedDate)}',
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: daysInWeek.map((day) {
              final bool isSelected = DateUtils.isSameDay(day, _selectedDay);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                    _filterTodosForSelectedDay();
                  });
                },
                child: Column(
                  children: [
                    Text(
                      DateFormat.E('vi_VN').format(day),
                      style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        DateFormat.d().format(day),
                        style: TextStyle(
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
    return const Center(
      child: Text(
        'Ngày này chưa có nhiệm vụ',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildTodoList() {
    final incompleteTodos = _todosForSelectedDay.where((t) => !t.isCompleted).toList();
    final completedTodos = _todosForSelectedDay.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (incompleteTodos.isNotEmpty)
          _buildTodoSection('Nhiệm vụ có ngày (${incompleteTodos.length})', incompleteTodos),

        if (completedTodos.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTodoSection('Các mục đã hoàn thành (${completedTodos.length})', completedTodos),
        ]
      ],
    );
  }

  Widget _buildTodoSection(String title, List<Todo> todos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...todos.map((todo) => _buildTodoItem(todo)).toList(),
      ],
    );
  }


  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: () => _toggleTodoStatus(todo),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (bool? value) {
            _toggleTodoStatus(todo);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          'Lúc: ${DateFormat.Hm('vi_VN').format(todo.startTime)}',
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
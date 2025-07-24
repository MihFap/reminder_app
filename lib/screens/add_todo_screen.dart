import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Import các file cần thiết
import 'package:reminder_app/model/todo_model.dart';
import 'package:reminder_app/screens/todo_detail.dart'; // Import màn hình chi tiết

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
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
      fetchTodos();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy người dùng. Vui lòng đăng nhập lại.')),
        );
      }
    }
  }

  Future<void> fetchTodos() async {
    if (_userId == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final uri = Uri.parse('http://172.16.7.146:5056/Todo/get?userId=$_userId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _allTodosForUser = data.map((json) => Todo.fromJson(json)).toList();
        _filterTodosForSelectedDay();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: ${response.reasonPhrase}')),
        );
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
    // Lọc ra các công việc cho ngày được chọn
    _todosForSelectedDay = _allTodosForUser.where((todo) {
      return DateUtils.isSameDay(todo.startTime, _selectedDay);
    }).toList();

    // --- PHẦN SẮP XẾP MỚI ---
    _todosForSelectedDay.sort((a, b) {
      // 1. Ưu tiên: Sắp xếp theo trạng thái hoàn thành
      // Công việc chưa hoàn thành (isCompleted = false) sẽ được xếp lên trước.
      if (a.isCompleted && !b.isCompleted) {
        return 1; // a (đã hoàn thành) sẽ đi sau b (chưa hoàn thành)
      }
      if (!a.isCompleted && b.isCompleted) {
        return -1; // a (chưa hoàn thành) sẽ đi trước b (đã hoàn thành)
      }

      // 2. Nếu cùng trạng thái, sắp xếp theo thời gian bắt đầu
      // Công việc có startTime sớm hơn sẽ được xếp lên trước.
      return a.startTime.compareTo(b.startTime);
    });
  }

  Future<void> _toggleTodoStatus(Todo todo) async {
    final newStatus = !todo.isCompleted;

    setState(() {
      todo.isCompleted = newStatus;
      _filterTodosForSelectedDay();
    });

    final patchDoc = [{'op': 'replace', 'path': '/isCompleted', 'value': newStatus}];

    try {
      final uri = Uri.parse("http://172.16.7.146:5056/Todo/update/${todo.id}");
      final response = await http.patch(
        uri,
        headers: {"Content-Type": "application/json-patch+json"},
        body: jsonEncode(patchDoc),
      );

      if (response.statusCode != 200 && mounted) {
        // Hoàn tác lại thay đổi trên UI nếu API thất bại
        setState(() {
          todo.isCompleted = !newStatus;
          _filterTodosForSelectedDay();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          todo.isCompleted = !newStatus;
          _filterTodosForSelectedDay();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối khi cập nhật: $e')),
        );
      }
    }
  }

  // --- HÀM XỬ LÝ SỬA VÀ XÓA ---
  void _editTodo(Todo todo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TodoDetailScreen(todoToEdit: todo),
      ),
    ).then((result) {
      if (result == true) {
        fetchTodos();
      }
    });
  }

  void _deleteTodo(Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa nhiệm vụ "${todo.title}" không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();

                final uri = Uri.parse('http://172.16.7.146:5056/Todo/delete?id=${todo.id}');
                final response = await http.delete(uri);

                if (response.statusCode == 200 && mounted) {
                  setState(() {
                    _allTodosForUser.removeWhere((item) => item.id == todo.id);
                    _filterTodosForSelectedDay();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa nhiệm vụ thành công.'), backgroundColor: Colors.green),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa nhiệm vụ thất bại.'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  // --- KẾT THÚC HÀM XỬ LÝ SỬA VÀ XÓA ---

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
                : _buildTodoList(), // Sửa lại để luôn gọi _buildTodoList
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
                      DateFormat.E('vi_VN').format(day).substring(0, 2),
                      style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.transparent,
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
    if (_todosForSelectedDay.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    final incompleteTodos = _todosForSelectedDay.where((t) => !t.isCompleted).toList();
    final completedTodos = _todosForSelectedDay.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (incompleteTodos.isNotEmpty)
          _buildTodoSection('Nhiệm vụ của ngày (${incompleteTodos.length})', incompleteTodos),
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
    // Biến để kiểm tra xem mô tả có tồn tại và không rỗng hay không
    final bool hasDescription = todo.description != null && todo.description!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        // Tự động điều chỉnh chiều cao nếu có mô tả
        isThreeLine: hasDescription,
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
        // --- PHẦN SUBTITLE ĐÃ ĐƯỢC CẬP NHẬT ---
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng 1: Hiển thị thời gian bắt đầu
            Text(
              'Lúc: ${DateFormat.Hm('vi_VN').format(todo.startTime)}',
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            // Dòng 2: Hiển thị mô tả nếu có
            if (hasDescription)
              Padding(
                padding: const EdgeInsets.only(top: 4.0), // Thêm một chút khoảng cách
                child: Text(
                  todo.description!,
                  maxLines: 1, // Chỉ hiển thị tối đa 1 dòng
                  overflow: TextOverflow.ellipsis, // Thêm "..." nếu mô tả quá dài
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editTodo(todo);
            } else if (value == 'delete') {
              _deleteTodo(todo);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Sửa'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
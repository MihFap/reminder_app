import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reminder_app/notification_service.dart';
import 'package:reminder_app/model/todo_model.dart';
import '../app_config.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo? todoToEdit;

  const TodoDetailScreen({super.key, this.todoToEdit});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  int? _userId;

  bool get _isEditing => widget.todoToEdit != null;

  Duration? _selectedReminder;
  final Map<String, Duration?> _reminderOptions = {
    'Không có': null,
    'Khi bắt đầu': Duration.zero,
    '5 phút trước': const Duration(minutes: 5),
    '15 phút trước': const Duration(minutes: 15),
    '30 phút trước': const Duration(minutes: 30),
    '1 giờ trước': const Duration(hours: 1),
    '1 ngày trước': const Duration(days: 1),
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
    _loadUserId();

    if (_isEditing) {
      final todo = widget.todoToEdit!;
      _titleController.text = todo.title;
      _descriptionController.text = todo.description ?? '';
      _startTime = todo.startTime;
      _endTime = todo.endTime;
    } else {
      _selectedReminder = _reminderOptions['15 phút trước'];
    }
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getInt('userId');
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_isEditing) {
      _updateTodo();
    } else {
      _createTodo();
    }
  }

  Future<void> _createTodo() async {
    final title = _titleController.text;
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tiêu đề.')));
      return;
    }

    DateTime remindAtTime = _selectedReminder != null ? _startTime.subtract(_selectedReminder!) : DateTime(1, 1, 1);

    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}/Todo/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": _userId,
        "title": title,
        "description": _descriptionController.text,
        "startTime": _startTime.toIso8601String(),
        "endTime": _endTime.toIso8601String(),
        "remindAt": remindAtTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 && mounted) {
      if (_selectedReminder != null && remindAtTime.isAfter(DateTime.now())) {
        await NotificationService().scheduleNotification(
          id: Random().nextInt(100000),
          title: 'Lời nhắc: $title',
          body: 'Nhiệm vụ của bạn sẽ bắt đầu lúc ${DateFormat('HH:mm').format(_startTime)}.',
          scheduledTime: remindAtTime,
        );
      }
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lưu thất bại: ${response.body}')));
    }
  }

  Future<void> _updateTodo() async {
    final originalTodo = widget.todoToEdit!;
    final patchDoc = <Map<String, dynamic>>[];

    if (_titleController.text != originalTodo.title) {
      patchDoc.add({'op': 'replace', 'path': '/title', 'value': _titleController.text});
    }
    if (_descriptionController.text != (originalTodo.description ?? '')) {
      patchDoc.add({'op': 'replace', 'path': '/description', 'value': _descriptionController.text});
    }
    if (_startTime != originalTodo.startTime) {
      patchDoc.add({'op': 'replace', 'path': '/startTime', 'value': _startTime.toIso8601String()});
    }
    if (_endTime != originalTodo.endTime) {
      patchDoc.add({'op': 'replace', 'path': '/endTime', 'value': _endTime.toIso8601String()});
    }

    if (patchDoc.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final uri = Uri.parse("${AppConfig.baseUrl}/Todo/update/${originalTodo.id}");
    final response = await http.patch(
      uri,
      headers: {"Content-Type": "application/json-patch+json"},
      body: jsonEncode(patchDoc),
    );

    if (response.statusCode == 200 && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: ${response.body}')));
    }
  }

  // --- CÁC HÀM BỊ THIẾU ĐÃ ĐƯỢC THÊM VÀO ĐÂY ---
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart ? _startTime : _endTime;
    final DateTime firstDate = DateTime.now().subtract(const Duration(days: 365));
    final DateTime lastDate = DateTime.now().add(const Duration(days: 365 * 5));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('vi', 'VN'),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _startTime.hour,
            _startTime.minute,
          );
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          _endTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _endTime.hour,
            _endTime.minute,
          );
        }
      });
    }
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
                  if (isStartTime) {
                    final newStartTime = DateTime(_startTime.year, _startTime.month, _startTime.day, selectedHour, selectedMinute);
                    _startTime = newStartTime;
                    if (_endTime.isBefore(_startTime.add(const Duration(hours: 1)))) {
                      _endTime = _startTime.add(const Duration(hours: 1));
                    }
                  } else {
                    final newEndTime = DateTime(_endTime.year, _endTime.month, _endTime.day, selectedHour, selectedMinute);
                    if (newEndTime.isAfter(_startTime)) {
                      _endTime = newEndTime;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thời gian kết thúc phải sau thời gian bắt đầu.')),
                      );
                    }
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
  // --- KẾT THÚC PHẦN THÊM VÀO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa nhiệm vụ' : 'Thêm nhiệm vụ'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _handleSave,
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
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              icon: Icon(Icons.description_outlined),
              hintText: 'Thêm miêu tả',
              border: InputBorder.none,
            ),
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bắt đầu"),
        const SizedBox(height: 8),
        _buildDateTimeRow(isStart: true),
        const SizedBox(height: 16),
        const Text("Kết thúc"),
        const SizedBox(height: 8),
        _buildDateTimeRow(isStart: false),
      ],
    );
  }

  Widget _buildDateTimeRow({required bool isStart}) {
    DateTime displayedTime = isStart ? _startTime : _endTime;
    String dateText = DateFormat('E, dd/MM/yyyy', 'vi_VN').format(displayedTime);
    String timeText = DateFormat('HH:mm').format(displayedTime);

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, isStart),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(dateText),
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () => _showCustomTimePicker(context, isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.notifications_outlined),
      title: const Text('Lời nhắc'),
      trailing: DropdownButton<Duration?>(
        value: _selectedReminder,
        underline: Container(),
        onChanged: (Duration? newValue) {
          setState(() {
            _selectedReminder = newValue;
          });
        },
        items: _reminderOptions.entries.map<DropdownMenuItem<Duration?>>((entry) {
          return DropdownMenuItem<Duration?>(
            value: entry.value,
            child: Text(entry.key),
          );
        }).toList(),
      ),
    );
  }
}
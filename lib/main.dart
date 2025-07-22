import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_todo_screen.dart'; // Import trang cài đặt
import 'package:intl/date_symbol_data_local.dart';
import 'screens/add_note_screen.dart';
import 'screens/note_detail.dart';
import 'screens/todo_detail.dart';

void main() async { // 1. Thêm 'async'
  // 2. Đảm bảo Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Khởi tạo dữ liệu ngôn ngữ 'vi_VN' cho package intl
  await initializeDateFormatting('vi_VN', null);

  // Chạy ứng dụng như bình thường
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lịch Flutter',
      themeMode: _themeMode,
      theme: ThemeData.light(), // Giao diện sáng
      darkTheme: ThemeData.dark(), // Giao diện tối
      home: HomePage(onThemeChanged: _toggleTheme, currentThemeMode: _themeMode),
      debugShowCheckedModeBanner: false, // Tắt banner debug
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentThemeMode;

  const HomePage({super.key, required this.onThemeChanged, required this.currentThemeMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> _appBarTitles = const [
    'Lịch Flutter',
    'To Do List',
    'Ghi chú',
    'Cài đặt'
  ];


  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Tạo Nhiệm vụ mới'),
                onTap: () {
                  // Đóng menu dưới
                  Navigator.of(context).pop();
                  // SỬA Ở ĐÂY: Điều hướng đến trang TodoDetailScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TodoDetailScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: const Text('Tạo Ghi chú mới'),
                onTap: () {
                  // Đóng menu dưới
                  Navigator.of(context).pop();
                  // Điều hướng đến trang NoteDetailScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NoteDetailScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tạo danh sách pages trong build để đảm bảo state luôn được cập nhật
    final List<Widget> pages = [
      CalendarScreen(),
      AddTodoScreen(),
      AddNoteScreen(),
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged,
        currentThemeMode: widget.currentThemeMode,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          // Sửa các Icon ở đây thành tên tiếng Anh chuẩn
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Nhiệm vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined), label: 'Ghi chú'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Gọi phương thức để hiển thị menu
          _showAddOptions(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
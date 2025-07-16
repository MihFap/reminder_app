import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart'; // Import trang cài đặt

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  // Thêm const và super.key vào constructor
  const MyApp({super.key});

  @override
  // Sửa kiểu trả về thành State<MyApp>
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

  // Thêm const và super.key vào constructor
  const HomePage({super.key, required this.onThemeChanged, required this.currentThemeMode});

  @override
  // Sửa kiểu trả về thành State<HomePage>
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Cải tiến: Thêm danh sách tiêu đề cho AppBar
  final List<String> _appBarTitles = const [
    'Lịch Flutter',
    'To Do List',
    'Ghi chú',
    'Cài đặt'
  ];

  // Logic cũ để tạo các trang vẫn giữ nguyên
  // (Chúng ta sẽ tạo nó trong build() để state luôn mới)

  @override
  Widget build(BuildContext context) {
    // Tạo danh sách pages trong build để đảm bảo state luôn được cập nhật
    final List<Widget> pages = [
      CalendarScreen(),
      const Center(child: Text('To do')),
      const Center(child: Text('Note')),
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
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'To do'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Note'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
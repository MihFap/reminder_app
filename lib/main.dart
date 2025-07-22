import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_todo_screen.dart';
import 'screens/add_note_screen.dart';
import 'screens/note_detail.dart';
import 'screens/todo_detail.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import đã thêm
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  // Dòng đã thêm: Khởi tạo NotificationService
  await NotificationService().init();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(isLoggedIn ? const MyAppWithHome() : const MyApp());
}

// Ứng dụng gốc: hiển thị màn hình đăng nhập
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lịch Flutter',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Hỗ trợ Tiếng Việt
        Locale('en', 'US'), // Hỗ trợ Tiếng Anh
      ],
      locale: const Locale('vi', 'VN'), // Đặt ngôn ngữ mặc định
      home: LoginScreen(), // Khởi động vào màn hình đăng nhập
    );
  }
}

// Ứng dụng chính sau khi đã đăng nhập
class MyAppWithHome extends StatefulWidget {
  const MyAppWithHome({super.key});

  @override
  State<MyAppWithHome> createState() => _MyAppWithHomeState();
}

class _MyAppWithHomeState extends State<MyAppWithHome> {
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Hỗ trợ Tiếng Việt
        Locale('en', 'US'), // Hỗ trợ Tiếng Anh
      ],
      locale: const Locale('vi', 'VN'), // Đặt ngôn ngữ mặc định
      home: HomePage(
        onThemeChanged: _toggleTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

// Trang chính sau khi đăng nhập
class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentThemeMode;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

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
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodoDetailScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: const Text('Tạo Ghi chú mới'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NoteDetailScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MyApp()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CalendarScreen(),
      AddTodoScreen(),
      AddNoteScreen(),
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged,
        currentThemeMode: widget.currentThemeMode,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Nhiệm vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined), label: 'Ghi chú'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
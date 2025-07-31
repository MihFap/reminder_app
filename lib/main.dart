import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reminder_app/screens/note_detail.dart';
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
import '../model/category_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_config.dart';

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

  final GlobalKey<AddTodoScreenState> _addTodoScreenKey = GlobalKey();
  final GlobalKey<AddNoteScreenState> _addNoteScreenKey = GlobalKey();

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
                  Navigator.of(context).pop(); // Đóng bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodoDetailScreen(),
                    ),
                  ).then((result) {
                    // Nếu thêm mới thành công, dùng key để gọi hàm fetchTodos()
                    if (result == true) {
                      _addTodoScreenKey.currentState?.fetchTodos();
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: const Text('Tạo Ghi chú mới'),
                // THAY THẾ TOÀN BỘ HÀM onTap BẰNG ĐOẠN CODE NÀY
                onTap: () async {
                  // Đóng bottom sheet trước
                  Navigator.of(context).pop();

                  // Lấy dữ liệu cần thiết
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('userId');

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lỗi: Không tìm thấy người dùng.")));
                    return;
                  }

                  // Tải danh sách categories
                  final catUri = Uri.parse("${AppConfig.baseUrl}/Category/get?userId=$userId");
                  final catResponse = await http.get(catUri);
                  if (catResponse.statusCode != 200) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lỗi: Không thể tải danh mục.")));
                    return;
                  }
                  final List<dynamic> catJsonList = jsonDecode(catResponse.body);
                  final categories = catJsonList.map((json) => Category.fromJson(json)).toList();

                  if (!mounted) return;

                  // Dùng `await` để chờ kết quả từ NoteDetailScreen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailScreen(
                        userId: userId,
                        categories: categories,
                      ),
                    ),
                  );

                  // Nếu kết quả là `true`, dùng GlobalKey để gọi hàm làm mới
                  if (result == true) {
                    _addNoteScreenKey.currentState?.fetchCategoriesAndNotes();
                  }
                },
              ),ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: const Text('Tạo Ghi chú mới'),
                // THAY THẾ TOÀN BỘ HÀM onTap BẰNG ĐOẠN CODE NÀY
                onTap: () async {
                  // Đóng bottom sheet trước
                  Navigator.of(context).pop();

                  // Lấy dữ liệu cần thiết
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('userId');

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lỗi: Không tìm thấy người dùng.")));
                    return;
                  }

                  // Tải danh sách categories
                  final catUri = Uri.parse("${AppConfig.baseUrl}/Category/get?userId=$userId");
                  final catResponse = await http.get(catUri);
                  if (catResponse.statusCode != 200) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lỗi: Không thể tải danh mục.")));
                    return;
                  }
                  final List<dynamic> catJsonList = jsonDecode(catResponse.body);
                  final categories = catJsonList.map((json) => Category.fromJson(json)).toList();

                  if (!mounted) return;

                  // Dùng `await` để chờ kết quả từ NoteDetailScreen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailScreen(
                        userId: userId,
                        categories: categories,
                      ),
                    ),
                  );

                  // Nếu kết quả là `true`, dùng GlobalKey để gọi hàm làm mới
                  if (result == true) {
                    _addNoteScreenKey.currentState?.fetchCategoriesAndNotes();
                  }
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
      AddTodoScreen(key: _addTodoScreenKey),
      AddNoteScreen(key: _addNoteScreenKey),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showAddOptions(context),
      //   backgroundColor: Colors.green,
      //   foregroundColor: Colors.white,
      //   child: const Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
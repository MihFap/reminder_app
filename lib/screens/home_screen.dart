import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'add_note_screen.dart';
import 'category_manager_screen.dart'; // 👈 thêm nếu bạn dùng quản lý danh mục

class MyAppWithHome extends StatefulWidget {
  const MyAppWithHome({super.key});

  @override
  State<MyAppWithHome> createState() => _MyAppWithHomeState();
}

class _MyAppWithHomeState extends State<MyAppWithHome> {
  int currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenContent(),
    const AddNoteScreen(),
    const CategoryManagerScreen(), // 👈 Thêm nếu dùng màn quản lý danh mục
  ];

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'Ghi chú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Danh mục',
          ),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Đã đăng nhập thành công',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

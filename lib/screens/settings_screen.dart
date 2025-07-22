import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reminder_app/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentThemeMode;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.onLogout, // thêm dòng này
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // QUAN TRỌNG: tên route phải là '/login' như đã khai báo ở bước trên
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chế độ giao diện:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Giao diện tối'),
              value: currentThemeMode == ThemeMode.dark,
              onChanged: onThemeChanged,
            ),
            const SizedBox(height: 24),

            const Divider(),

            // Nút đăng xuất
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: onLogout, // gọi sự kiện
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Nút màu xanh cho dễ phân biệt
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Gọi hàm test khi nhấn nút
                NotificationService().showTestNotification();
              },
              child: const Text('Gửi thông báo Test ngay'),
            ),
          ],
        ),
      ),
    );
  }
}

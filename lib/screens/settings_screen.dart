import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentThemeMode;

  // Thêm 'const' và 'super.key' vào constructor
  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Thêm 'const'
        title: const Text('Cài đặt'),
      ),
      body: Padding(
        // Thêm 'const'
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thêm 'const'
            const Text(
              'Chế độ giao diện:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              // Thêm 'const'
              title: const Text('Giao diện tối'),
              value: currentThemeMode == ThemeMode.dark,
              // Đơn giản hóa callback
              onChanged: onThemeChanged,
            ),
            // Các cài đặt khác có thể thêm ở đây
          ],
        ),
      ),
    );
  }
}
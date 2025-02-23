import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaiDatUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài Đặt Người Dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: Add change password functionality
              },
              child: Text('Đổi Mật Khẩu'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _logout(context);
              },
              child: Text('Đăng Xuất'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Add view personal information functionality
              },
              child: Text('Xem Thông Tin Cá Nhân'),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Clear user session or token here
    // For example, using SharedPreferences to clear the token
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('token');
      prefs.remove('userName');
      // Navigate to the login screen
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }
}
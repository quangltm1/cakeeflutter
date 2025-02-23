import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaiDatAdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài Đặt Admin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle Đăng Xuất action
                _logout(context);
              },
              child: Text('Đăng Xuất'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle Đổi Mật Khẩu action
              },
              child: Text('Đổi Mật Khẩu'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle Xem Thông Tin Tài Khoản action
              },
              child: Text('Xem Thông Tin Tài Khoản'),
            ),
          ],
        ),
      ),
    );
  }
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

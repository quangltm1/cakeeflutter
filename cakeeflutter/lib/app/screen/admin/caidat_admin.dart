import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaiDatAdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt', style: TextStyle(), textAlign: TextAlign.center),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingItem(
              icon: Icons.person_outline,
              label: 'Chỉnh sửa tài khoản',
              onTap: () {
                // Chuyển hướng đến trang chỉnh sửa tài khoản
              },
              trailing: const Icon(Icons.chevron_right, color: Colors.black),
            ),
            _buildSettingItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Ví',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.location_on_outlined,
              label: 'Lưu địa chỉ',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.cake_outlined,
              label: 'Sinh nhật',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.settings_outlined,
              label: 'Cài đặt',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.help_outline,
              label: 'Hỗ trợ',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.logout,
              label: 'Đăng Xuất',
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo từng mục trong danh sách cài đặt
  Widget _buildSettingItem({required IconData icon, required String label, required VoidCallback onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFFFD900), size: 28),
      title: Text(label, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  

  // Hàm xử lý Đăng Xuất
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/trang-chu');
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaiDatUserScreen extends StatefulWidget {
  @override
  _CaiDatUserScreenState createState() => _CaiDatUserScreenState();
}

class _CaiDatUserScreenState extends State<CaiDatUserScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      isLoggedIn = token != null; // Nếu có token => Đã đăng nhập
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoggedIn ? _buildSettingsList() : _buildLoginButton(),
      ),
    );
  }

  /// ✅ **Hiển thị danh sách cài đặt nếu đã đăng nhập**
  Widget _buildSettingsList() {
    return Column(
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
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  /// 🔹 **Hiển thị nút đăng nhập nếu chưa đăng nhập**
  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login'); // Chuyển đến trang login
        },
        child: const Text("Đăng Nhập", style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  /// 🛠 **Widget tạo từng mục trong danh sách cài đặt**
  Widget _buildSettingItem({required IconData icon, required String label, required VoidCallback onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange, size: 28),
      title: Text(label, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// ❌ **Xử lý đăng xuất**
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa token
    setState(() {
      isLoggedIn = false;
    });
    Navigator.of(context).pushReplacementNamed('/login');
  }
}

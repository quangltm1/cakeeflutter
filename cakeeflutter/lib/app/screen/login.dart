import 'package:cakeeflutter/app/core/api_service.dart';
import 'package:cakeeflutter/app/core/shared_prefs.dart';
import 'package:cakeeflutter/app/screen/admin/dashboard_admin.dart';
import 'package:cakeeflutter/app/screen/user/dashboard_user.dart';
import 'package:cakeeflutter/app/screen/register_user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController accountController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  login() async {
  setState(() {
    isLoading = true;
  });

  String? token = await APIRepository().login(
    accountController.text,
    passwordController.text,
  );

  if (token != null) {
    var user = await APIRepository().current(token);
    if (user != null) {
      await saveUser(user);

      // Debug kiểm tra giá trị role nhận được
      print("🔍 Giá trị role từ API: ${user.role} (kiểu dữ liệu: ${user.role.runtimeType})");

      // Xóa dữ liệu cũ trước khi lưu mới
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Ép kiểu role thành int trước khi lưu
      int userRole = int.tryParse(user.role.toString()) ?? 0;

      // Lưu token & role mới
      await prefs.setString('token', token);
      await prefs.setInt('role', userRole);

      print("✅ Đăng nhập thành công! Role mới đã lưu: $userRole");

      // Điều hướng theo role
      if (userRole == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy thông tin người dùng")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đăng nhập thất bại!")),
    );
  }

  setState(() {
    isLoading = false;
  });
}

  @override
  void initState() {
    super.initState();
  }

  autoLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  int? savedRole = prefs.getInt('role'); // Lấy role từ SharedPreferences

  print("🔍 AutoLogin - Token: $token, Role từ SharedPreferences: $savedRole");

  if (token != null && token.isNotEmpty) {
    var user = await APIRepository().current(token);

    if (user != null) {
      // Debug giá trị role từ API
      print("✅ AutoLogin - Role từ API: ${user.role} (kiểu dữ liệu: ${user.role.runtimeType})");

      int userRole = int.tryParse(user.role.toString()) ?? 0;
      await prefs.setInt('role', userRole);

      print("✅ AutoLogin - Role sau khi cập nhật: $userRole");

      if (userRole == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
        );
      }
    } else {
      await prefs.clear();
      print("❌ AutoLogin failed, removed token.");
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD900),
        title: Text('Đăng nhập'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Image.asset('assets/images/logo.png'),
            SizedBox(height: 20),
            TextField(
              controller: accountController,
              decoration: InputDecoration(
                labelText: 'Nhập tài khoản',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Nhập mật khẩu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD900)),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text('Đăng nhập', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD900)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterUserScreen()),
                    );
                  },
                  child: Text('Đăng ký', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

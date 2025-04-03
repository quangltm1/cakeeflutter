import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/core/base_service.dart';
import 'package:cakeeflutter/app/core/shared_prefs.dart';
import 'package:cakeeflutter/app/widgets/dashboard_admin.dart';
import 'package:cakeeflutter/app/widgets/dashboard_user.dart';
import 'package:cakeeflutter/app/screen/register_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false; // Thêm trạng thái hiển thị mật khẩu

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      String? token = await APIRepository().login(
        accountController.text,
        passwordController.text,
      );

      if (token != null) {
        var user = await APIRepository().current(token);
        if (user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('userId', user.id.toString()); // ⚡ Lưu userId
          await prefs.setInt('role', int.tryParse(user.role.toString()) ?? 0);

          print(
              "✅ Lưu vào SharedPreferences: UserID = ${user.id}, Token = $token");

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => user.role == 1
                  ? const AdminHomeScreen()
                  : const UserHomeScreen(),
            ),
            (route) => false, // Xóa tất cả các route trước đó
          );
        } else {
          showError("Không thể lấy thông tin người dùng");
        }
      } else {
        showError("Sai tên đăng nhập hoặc mật khẩu");
      }
    } catch (e) {
      showError("Đã xảy ra lỗi, vui lòng thử lại");
    }

    setState(() => isLoading = false);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              "Đăng nhập",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            buildTextField("Tên đăng nhập", accountController),
            const SizedBox(height: 10),
            buildTextField("Mật khẩu", passwordController, obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD900),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      "Đăng nhập",
                      style: TextStyle(color: Colors.black),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Chưa có tài khoản?"),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterUserScreen())),
                  child: const Text(
                    "Đăng ký",
                    style: TextStyle(color: const Color(0xFFFFD900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText && !isPasswordVisible,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}

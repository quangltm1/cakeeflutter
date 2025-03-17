import 'package:cakeeflutter/app/model/register.dart';
import 'package:dio/dio.dart';
import 'package:cakeeflutter/app/core/base_service.dart'; // Import API service
import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/screen/login.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;
  bool isSeller = false;

  /// ✅ **Gửi request đăng ký**
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return; // Nếu form không hợp lệ, dừng lại

    setState(() {
      isLoading = true;
    });

    Signup user = Signup(
      userName: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    try {
      APIRepository apiRepository = APIRepository(); // Khởi tạo service API
      String result = await apiRepository.register(user, isSeller);

      if (result == "ok") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Đăng ký thành công!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $result')), // Hiển thị lỗi từ API
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi đăng ký: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              /// 🔙 **Nút quay lại**
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Image.asset('assets/images/logo.png', height: 100),
              SizedBox(height: 20),
              Text(
                "Tạo tài khoản",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_emailController, "Tên đăng nhập", Icons.person),
                    _buildTextField(_fullNameController, "Tên đầy đủ", Icons.account_circle_sharp),
                    _buildTextField(_phoneController, "Số điện thoại", Icons.phone),
                    _buildTextField(_passwordController, "Mật khẩu", Icons.lock, obscure: true),
                    _buildTextField(_confirmPasswordController, "Xác nhận mật khẩu", Icons.lock, obscure: true),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: isSeller,
                          onChanged: (bool? value) {
                            setState(() {
                              isSeller = value ?? false;
                            });
                          },
                        ),
                        Text("Đăng ký cho nhà bán hàng"),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD900),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Đăng ký", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $hintText';
          }
          return null;
        },
      ),
    );
  }
}

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;
  bool isSeller = false;

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      // Simulate registration process
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thành công!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
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

              /// ✅ Thêm nút "Quay lại"
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  onPressed: () {
                    Navigator.pop(context); // ✅ Quay lại màn hình trước đó
                  },
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
                    _buildTextField(
                      _emailController,
                      "Tên đăng nhập",
                      Icons.person,
                      validator: (value) =>
                          value!.isEmpty ? "Vui lòng nhập tên đăng nhập" : null,
                    ),
                    _buildTextField(
                      _fullNameController,
                      "Tên đầy đủ",
                      Icons.account_circle_sharp,
                      maxLength: 50,
                      validator: (value) =>
                          value!.isEmpty ? "Vui lòng nhập tên đầy đủ" : null,
                    ),
                    _buildTextField(
                      _phoneController,
                      "Số điện thoại",
                      Icons.phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      validator: (value) {
                        if (value!.isEmpty)
                          return "Vui lòng nhập số điện thoại";
                        if (!RegExp(r"^\+84\d{8,9}$|^0\d{9,10}$")
                            .hasMatch(value)) {
                          return "Vui lòng nhập đúng số điện thoại";
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      _passwordController,
                      "Mật khẩu",
                      Icons.lock,
                      obscure: true,
                      validator: (value) => value!.length < 6
                          ? "Mật khẩu tối thiểu 6 ký tự"
                          : null,
                    ),
                    _buildTextField(
                      _confirmPasswordController,
                      "Xác nhận mật khẩu",
                      Icons.lock,
                      obscure: true,
                      validator: (value) => value != _passwordController.text
                          ? "Mật khẩu không khớp"
                          : null,
                    ),
                    SizedBox(height: 20),

                    // ✅ Nút "Đăng ký" đã bị thiếu
                    ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD900),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Đăng ký",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon,
      {bool obscure = false,
      String? Function(String?)? validator,
      TextInputType? keyboardType,
      int maxLength = 50}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength, // ✅ Giới hạn ký tự
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          counterText: "", // ✅ Ẩn bộ đếm ký tự
        ),
        validator: validator, // ✅ Áp dụng validator riêng cho từng trường
      ),
    );
  }
}

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  
  bool isLoading = false;
  bool isSeller = false;
  String? phoneError; // 🔹 Biến lưu lỗi số điện thoại nếu đã tồn tại
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool phoneToFocus = false;
  bool passwordToFocus = false;
  bool confirmPasswordToFocus = false;
  bool fullNameToFocus = false;
  bool emailToFocus = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() {
      if (!_phoneFocus.hasFocus && _phoneController.text.isNotEmpty && _phoneController.text.length >= 10) {
        _checkPhoneExists(_phoneController.text);
      }
    });
    
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _fullNameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

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

  /// 🔍 **Kiểm tra số điện thoại đã tồn tại**
  Future<void> _checkPhoneExists(String phone) async {
    try {
      var response = await Dio().get(
        "https://your-api.com/check-phone/$phone",
      );
      if (response.data['exists']) {
        setState(() {
          phoneError = "❌ Số điện thoại đã được sử dụng!";
        });
      } else {
        setState(() {
          phoneError = null;
        });
      }
    } catch (e) {
      print("❌ Lỗi kiểm tra số điện thoại: $e");
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
                autovalidateMode: AutovalidateMode.onUserInteraction, // ✅ Validate khi nhập
                child: Column(
                  children: [
                    _buildUsernameField(),
                    _buildFullNameField(),
                    _buildPhoneField(), // ✅ Trường số điện thoại có validate real-time
                    _buildPasswordField(),
                    _buildConfirmPasswordField(),
                    SizedBox(height: 20),
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

  /// 📱 **Trường nhập số điện thoại với kiểm tra lỗi real-time**
  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        maxLength: 11, // ✅ Chặn nhập quá 11 số
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone, color: Colors.grey),
          hintText: "Số điện thoại",
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          counterText: "", // ✅ Ẩn bộ đếm ký tự
          errorText: phoneToFocus? phoneError : null, // ✅ Hiển thị lỗi nếu số điện thoại đã tồn tại
        ),
        onChanged: (value) {
          setState(() {
            phoneToFocus = true;
          });
          if (value.length >= 10) {
            _checkPhoneExists(value); // 🔍 Kiểm tra số điện thoại sau khi nhập đủ số
          }
        },
        validator: (value) {
          if (value == null) return "Vui lòng nhập số điện thoại";
          if (!RegExp(r"^\+84\d{8,9}$|^0\d{9,10}$").hasMatch(value)) {
            return "Vui lòng nhập đúng số điện thoại";
          }
          return null;
        },
      ),
    );
  }

  /// 📱 **Trường nhập tên đăng nhập với kiểm tra lỗi real-time**
  Widget _buildUsernameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        maxLength: 50,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: Colors.grey),
          hintText: "Tên đăng nhập",
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          counterText: "",
        ),
        validator: (value) {
          if (value == null) return "Vui lòng nhập tên đăng nhập";
          if (!RegExp(r"^[a-zA-Z0-9._-]{3,}$").hasMatch(value)) {
            return "Tên đăng nhập ít nhất 3 ký tự";
          }
          return null;
        },
      ),
    );
  }

  /// 📱 **Trường nhập tên đầy đủ với kiểm tra lỗi real-time**
  Widget _buildFullNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _fullNameController,
        keyboardType: TextInputType.name,
        maxLength: 50,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle, color: Colors.grey),
          hintText: "Tên đầy đủ",
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          counterText: "",
        ),
        validator: (value) {
          if (value == null) return "Vui lòng nhập tên của bạn";
          if (value.length < 3) return "Tên đầy đủ phải có ít nhất 3 ký tự";
          return null;
        },
      ),
    );
  }

  /// 📱 **Trường nhập mật khẩu và xác nhận mật khẩu với kiểm tra lỗi real-time**
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        maxLength: 50,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.grey),
          hintText: "Mật khẩu",
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          counterText: "",
        ),
        validator: (value) {
          if (value == null) return "Vui lòng nhập mật khẩu";
          if (value.length < 6) return "Mật khẩu phải có ít nhất 6 ký tự";
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: true,
        maxLength: 50,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.grey),
          hintText: "Xác nhận mật khẩu",
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          counterText: "",
        ),
        validator: (value) {
          if (value == null) return "Vui lòng xác nhận mật khẩu";
          if (value != _passwordController.text) return "Mật khẩu không khớp";
          return null;
        },
      ),
    );
  }
  
  
  

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon,
      {bool obscure = false, String? Function(String?)? validator, TextInputType? keyboardType, int maxLength = 50}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          counterText: "",
        ),
        validator: validator,
      ),
    );
  }
}

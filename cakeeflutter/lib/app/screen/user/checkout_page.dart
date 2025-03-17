import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final String cakeId;
  final String userId;
  final String cakeName;

  CheckoutPage({
    required this.cakeId,
    required this.userId,
    required this.cakeName,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>(); // 🔥 Thêm key cho form
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int _quantity = 1;
  bool _isLoading = false;
  String? _shopId;

  @override
  void initState() {
    super.initState();
    _getShopId();
    _getUserPhone();
  }

  Future<void> _getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String? phone = decodedToken["phone_number"];

        if (phone != null && phone.isNotEmpty) {
          await prefs.setString('phone', phone);
          setState(() {
            _phoneController.text = phone;
          });
        }
      } catch (e) {
        print("❌ Lỗi khi giải mã token: $e");
      }
    }
  }

  Future<void> _getShopId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shopId = prefs.getString('userId');
    });
  }

  // 🔥 Hàm kiểm tra số điện thoại hợp lệ
  String? _phoneError; // 🔥 Biến lưu lỗi hiển thị ngay

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập số điện thoại";
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value)) {
      return "Vui lòng nhập đúng số điện thoại (10-11 số)";
    }

    if (RegExp(r'^[1-9]').hasMatch(value)) {
      return "Số điện thoại phải bắt đầu bằng +84 hoặc 0";
    }

    if (value.startsWith('+') && !value.startsWith('+84')) {
      return "Số điện thoại phải bắt đầu bằng +84 hoặc 0";
    }

    return null; // ✅ Hợp lệ
  }

  // 🔥 **Hàm validate địa chỉ**
  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập địa chỉ";
    }
    return null;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return; // Dừng nếu form không hợp lệ
    }

    if (_shopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không tìm thấy shopId!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn cần đăng nhập để đặt hàng!")),
      );
      return;
    }

    final url =
        "https://fitting-solely-fawn.ngrok-free.app/api/Bill/CreateBill";

    final data = {
      "BillDeliveryAddress": _addressController.text,
      "BillDeliveryPhone": _phoneController.text,
      "BillCakeId": widget.cakeId,
      "BillCakeQuantity": _quantity,
      "BillNote": _noteController.text,
      "BillCakeContent": _contentController.text,
      "BillShopId": _shopId,
    };

    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đặt hàng thành công!")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Lỗi API");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đặt hàng, vui lòng thử lại!")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thanh toán")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // 🔥 Thêm formKey để validate
          child: Column(
            children: [
              Text("Bánh: ${widget.cakeName}", style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Số lượng: $_quantity", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Địa chỉ giao hàng"),
                maxLength: 250, 
                validator: _validateAddress, // 🔥 Thêm validate địa chỉ
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  errorText: _phoneError, // 🔥 Hiển thị lỗi nếu nhập sai
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11, // 🔥 Giới hạn số lượng ký tự nhập tối đa 11 số
                onChanged: (value) {
                  setState(() {
                    _phoneError =
                        _validatePhone(value); // 🔥 Kiểm tra lỗi ngay khi nhập
                  });
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Ghi chú đơn hàng"),
                maxLength: 250, 
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: "Nội dung bánh"),
                maxLength: 250,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _placeOrder,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("🛒 Đặt hàng"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("❌ Hủy"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

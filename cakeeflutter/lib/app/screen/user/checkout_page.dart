import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _contentController = TextEditingController(); // Bill content
  int _quantity = 1;
  bool _isLoading = false;
  String? _shopId; // Variable to store shopId

  @override
  void initState() {
    super.initState();
    _getShopId(); // Retrieve shopId when the page is initialized
  }

  // Get shopId from SharedPreferences
  Future<void> _getShopId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shopId = prefs.getString('userId'); // Retrieve shopId
    });
  }

  // Place order
  Future<void> _placeOrder() async {
    if (_addressController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
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
    final token = prefs.getString('token'); // Get token from shared preferences

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn cần đăng nhập để đặt hàng!")),
      );
      return;
    }

    final url = "https://fitting-solely-fawn.ngrok-free.app/api/Bill/CreateBill";

    final data = {
      "BillDeliveryAddress": _addressController.text,
      "BillDeliveryPhone": _phoneController.text,
      "BillCakeId": widget.cakeId,
      "BillCakeQuantity": _quantity,
      "BillNote": _noteController.text,
      "BillCakeContent": _contentController.text,
      "BillShopId": _shopId,  // Include shopId in the request
    };

    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: {
          "Authorization": "Bearer $token", // Include token in header
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
            
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: "Địa chỉ giao hàng"),
            ),
            
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Số điện thoại"),
              keyboardType: TextInputType.phone,
            ),
            
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: "Ghi chú đơn hàng"),
            ),
            
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: "Nội dung bánh"),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

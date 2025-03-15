import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class GuestOrderPage extends StatefulWidget {
  final String cakeId;
  final int quantity;

  GuestOrderPage({required this.cakeId, required this.quantity});

  @override
  _GuestOrderPageState createState() => _GuestOrderPageState();
}

class _GuestOrderPageState extends State<GuestOrderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  /// 🛒 **Gửi yêu cầu đặt hàng**
  Future<void> _placeOrder() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dio = Dio();
    final url = "https://fitting-solely-fawn.ngrok-free.app/api/Bill/CreateBillForGuest";

    final data = {
      "BillDeliveryPhone": _phoneController.text,
      "BillDeliveryAddress": _addressController.text,
      "BillCakeId": widget.cakeId,
      "BillCakeQuantity": widget.quantity,
    };

    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Đặt hàng thành công!")),
        );
        Navigator.pop(context); // Quay về trang trước
      } else {
        throw Exception("Lỗi API");
      }
    } catch (e) {
      print("❌ Lỗi đặt hàng: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi đặt hàng, vui lòng thử lại!")),
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
      appBar: AppBar(title: Text("Nhập thông tin đặt hàng")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Tên khách hàng"),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Số điện thoại"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: "Địa chỉ nhận hàng"),
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

import 'package:cakeeflutter/app/core/bill_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutNologinPage extends StatefulWidget {
  final Map<String, dynamic> product;

  CheckoutNologinPage({required this.product});

  @override
  _CheckoutNologinPageState createState() => _CheckoutNologinPageState();
}

class _CheckoutNologinPageState extends State<CheckoutNologinPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> orderData = {
      "customName": _nameController.text,
      "address": _addressController.text,
      "phone": _phoneController.text,
      "cakeName": widget.product["cakeName"],
      "cakeSize": widget.product["cakeSize"],
      "total": widget.product["cakePrice"],
      "quantity": 1,
    };

    bool success = await BillService.createBill(orderData);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đặt hàng thành công!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Xác nhận đơn hàng")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_isLoggedIn) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Họ và Tên"),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập tên" : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: "Địa chỉ"),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Số điện thoại"),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _placeOrder,
                child: Text("Đặt hàng"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

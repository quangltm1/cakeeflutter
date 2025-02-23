import 'package:flutter/material.dart';

class DonHangPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn Hàng'),
      ),
      body: Center(
        child: Text('Đây là trang Đơn Hàng của người dùng'),
      ),
    );
  }
}
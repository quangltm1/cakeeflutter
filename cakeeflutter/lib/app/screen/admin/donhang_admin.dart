import 'package:flutter/material.dart';

class DonHangAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn Hàng', style: TextStyle(), textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Text('Quản lý đơn hàng'),
      ),
    );
  }
}
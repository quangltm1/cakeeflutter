import 'package:flutter/material.dart';

class TrangChu extends StatefulWidget {
  @override
  _TrangChuState createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trang Chủ')),
      body: Center(
        child: Text("Trang Chủ screen", style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
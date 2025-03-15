import 'package:flutter/material.dart';

class DoanhthuAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doanh Thu', style: TextStyle(), textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: Color(0xFFFFD900),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Text('Welcome to Doanh Thu Admin Screen'),
      ),
    );
  }
}
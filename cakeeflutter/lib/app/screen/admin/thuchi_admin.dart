import 'package:flutter/material.dart';

class ThuChiAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thu Chi', style: TextStyle(), textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: Color(0xFFFFD900),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Text('Welcome to Thu Chi Admin Screen'),
      ),
    );
  }
}
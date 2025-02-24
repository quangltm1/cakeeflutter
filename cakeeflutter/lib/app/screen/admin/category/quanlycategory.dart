import 'package:flutter/material.dart';

class QuanLyCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Category'),
      ),
      body: Center(
        child: Text('Quản lý các danh mục ở đây'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
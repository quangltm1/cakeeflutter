import 'package:cakeeflutter/app/widgets/order_cart.dart';
import 'package:flutter/material.dart';

class DonHangPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders = [
    {'shop': 'Chi Na Bakery', 'date': 'Apr 6, 2022', 'total': 400000, 'status': 'Đang giao hàng'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đơn hàng của tôi")),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            shop: order['shop'],
            date: order['date'],
            total: order['total'],
            status: order['status'],
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String shop;
  final String date;
  final int total;
  final String status;

  const OrderCard({super.key, required this.shop, required this.date, required this.total, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(shop, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$date - $status'),
        trailing: Text('$total đ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/core/bill_service.dart';
import 'package:cakeeflutter/app/model/bill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DonHangPage extends StatefulWidget {
  @override
  _DonHangPageState createState() => _DonHangPageState();
}

class _DonHangPageState extends State<DonHangPage> {
  final BillService _billService = BillService();
  List<Bill> orders = [];
  bool isLoading = true;
  Timer? _timer;
  String? lastUpdate; // Lưu timestamp của lần cập nhật cuối

  @override
  void initState() {
    super.initState();
    _loadBills(); 
    _startPolling(); 
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _loadBills();
    });
  }

  Future<void> _loadBills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? customerId = prefs.getString("userId");

      if (customerId == null || customerId.isEmpty) {
        return;
      }

      final fetchedOrders = await _billService.getBillOfCustom(customerId);
      final newUpdate = DateTime.now().toIso8601String(); // Lưu timestamp mới

      if (lastUpdate == null || fetchedOrders.toString() != orders.toString()) {
        setState(() {
          orders = fetchedOrders;
          lastUpdate = newUpdate; 
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Lỗi khi tải đơn hàng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đơn hàng của tôi")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(child: Text("Không có đơn hàng nào"))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final Bill order = orders[index];
                    return Card(
                      child: ListTile(
                        title: Text("Bánh: ${order.cakeName}"),
                        subtitle: Text(
                          "Ngày giao: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(order.deliveryDate))}\n"
                          "Tổng tiền: ${NumberFormat('#,###').format(order.total)} VNĐ\n"
                          "Số lượng: ${order.quantity}",
                        ),
                        trailing: Text(
                          order.status == 0
                              ? "Đã giao"
                              : order.status == 1
                                  ? "Đang chờ nhận đơn"
                                  : order.status == 2
                                      ? "Đang chuẩn bị"
                                      : "Đang giao",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

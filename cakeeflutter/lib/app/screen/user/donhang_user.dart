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

class _DonHangPageState extends State<DonHangPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BillService _billService = BillService();
  List<Bill> orders = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBills();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
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
      throw Exception("User ID không tồn tại");
    }

    print("Customer ID: $customerId");  // Debugging the customer ID

    final fetchedOrders = await _billService.getBillOfCustom(customerId);

    if (!mounted) return;

    setState(() {
      orders = fetchedOrders;
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
    print("Lỗi khi tải đơn hàng: $e");
  }
}


  List<Bill> getOrdersByStatus(int status) {
    return orders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đơn hàng của tôi"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Đang chờ nhận"),
            Tab(text: "Đang chuẩn bị"),
            Tab(text: "Đang giao"),
            Tab(text: "Đã giao"),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(getOrdersByStatus(1)), // Đang chờ nhận
                _buildOrderList(getOrdersByStatus(2)), // Đang chuẩn bị
                _buildOrderList(getOrdersByStatus(3)), // Đang giao
                _buildOrderList(getOrdersByStatus(0)), // Đã giao
              ],
            ),
    );
  }

  Widget _buildOrderList(List<Bill> filteredOrders) {
    if (filteredOrders.isEmpty) {
      return Center(child: Text("Không có đơn hàng nào"));
    }

    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final Bill order = filteredOrders[index];
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: order.status == 0 ? Colors.green : Colors.orange,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonHangAdmin extends StatefulWidget {
  @override
  _DonHangAdminState createState() => _DonHangAdminState();
}

class _DonHangAdminState extends State<DonHangAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allBills = [];
  String? currentShopId; // ✅ ID của shop hiện tại

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getShopIdAndFetchBills();
  }

  Future<void> _getShopIdAndFetchBills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? shopId = prefs.getString("userId");
    print("🔍 ShopId: $shopId");

    if (shopId != null && shopId.isNotEmpty) {
      setState(() {
        currentShopId = shopId;
      });
      _fetchBills(shopId);
    } else {
      print("❌ Không tìm thấy ShopId");
    }
  }

  Future<void> _fetchBills(String shopId) async {
    try {
      var response = await Dio().get("https://fitting-solely-fawn.ngrok-free.app/api/Bill/GetAllBill");

      if (response.statusCode == 200) {
        setState(() {
          allBills = response.data.where((bill) => bill["billShopId"] == shopId).toList();
        });
      }
    } catch (e) {
      print("❌ Lỗi lấy danh sách đơn hàng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý đơn hàng"),
        centerTitle: true,
        backgroundColor: Color(0xFFFFD900),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.blueGrey,
          indicatorColor: Colors.black,
          tabs: [
            Tab(text: "Chờ xử lý"),
            Tab(text: "Đang xử lý"),
            Tab(text: "Đang giao"),
            Tab(text: "Hoàn thành"),
          ],
        ),
      ),
      body: currentShopId == null
          ? Center(child: CircularProgressIndicator()) // ⏳ Loading nếu chưa lấy được ShopId
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(1), // Chờ xử lý
                _buildOrderList(2), // Đang xử lý
                _buildOrderList(3), // Đang giao
                _buildOrderList(0), // Hoàn thành
              ],
            ),
    );
  }

  /// ✅ **Hiển thị danh sách đơn hàng theo trạng thái**
  Widget _buildOrderList(int status) {
    List<dynamic> filteredBills = allBills.where((bill) => bill["status"] == status).toList();

    if (filteredBills.isEmpty) {
      return Center(child: Text("Không có đơn hàng nào."));
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchBills(currentShopId!), // ✅ Cập nhật danh sách đơn hàng
      child: ListView.builder(
        itemCount: filteredBills.length,
        itemBuilder: (context, index) {
          var bill = filteredBills[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.receipt, color: Colors.orange),
              title: Text("Khách: ${bill["customName"] ?? "Chưa có"}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text("Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '').format(bill["total"])} VNĐ"),
                  Text("Giao hàng: ${bill["deliveryDate"]}"),
                  Text("Trạng thái: ${_getStatusText(bill["status"])}"),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showOrderDetail(context, bill);
              },
            ),
          );
        },
      ),
    );
  }

  /// ✅ **Chuyển `BillStatus` thành chữ dễ hiểu**
  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return "Chờ xử lý";
      case 2:
        return "Đang xử lý";
      case 3:
        return "Đang giao";
      case 0:
        return "Hoàn thành";
      default:
        return "Không xác định";
    }
  }

  /// ✅ **Hiển thị chi tiết đơn hàng**
  void _showOrderDetail(BuildContext context, dynamic bill) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Chi tiết đơn hàng"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Tên khách: ${bill["customName"]}"),
              Text("Số điện thoại: ${bill["phone"]}"),
              Text("Địa chỉ: ${bill["address"]}"),
              Text("Ghi chú: ${bill["note"]}"),
              Divider(),
              Text("Bánh: ${bill["cakeName"]}"),
              Text("Nội dung: ${bill["cakeContent"]}"),
              Text("Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '').format(bill["total"])} VNĐ"),
              Text("Giao hàng: ${bill["deliveryDate"]}"),
              Text("Trạng thái: ${_getStatusText(bill["status"])}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Đóng"),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonHangAdmin extends StatefulWidget {
  @override
  _DonHangAdminState createState() => _DonHangAdminState();
}

class _DonHangAdminState extends State<DonHangAdmin>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allBills = [];
  String? currentShopId;
  bool isLoading = true; // ✅ Biến trạng thái loading

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getShopIdAndFetchBills();
  }

  /// 🛠 **Lấy ShopId và đơn hàng**
  Future<void> _getShopIdAndFetchBills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? shopId = prefs.getString("userId");
    print("🔍 ShopId: $shopId");

    if (shopId != null && shopId.isNotEmpty) {
      setState(() {
        currentShopId = shopId;
      });
      await _fetchBills(shopId);
    } else {
      print("❌ Không tìm thấy ShopId");
      setState(() {
        isLoading = false; // ✅ Tắt trạng thái loading khi lỗi
      });
    }
  }

  /// 🛒 **Lấy danh sách đơn hàng**
  Future<void> _fetchBills(String shopId) async {
    try {
      if (!mounted) return; // ✅ Kiểm tra widget đã bị dispose chưa
      setState(() {
        isLoading = true;
      });

      var response = await Dio().get(
          "https://fitting-solely-fawn.ngrok-free.app/api/Bill/GetAllBill");

      if (response.statusCode == 200) {
        List<dynamic> bills = response.data;
        List<dynamic> shopBills =
            bills.where((bill) => bill["billShopId"] == shopId).toList();

        print("🔹 Đơn hàng của ShopId $shopId: $shopBills");

        if (mounted) {
          // ✅ Kiểm tra lại trước khi gọi setState()
          setState(() {
            allBills = shopBills;
          });
        }
      }
    } catch (e) {
      print("❌ Lỗi lấy danh sách đơn hàng: $e");
    } finally {
      if (mounted) {
        // ✅ Kiểm tra lại trước khi gọi setState()
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _changeBillStatus(dynamic bill) async {
    int currentStatus = bill["status"];
    int newStatus;

    switch (currentStatus) {
      case 1:
        newStatus = 2;
        break;
      case 2:
        newStatus = 3;
        break;
      case 3:
        newStatus = 0;
        break;
      default:
        newStatus = 1;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token"); // 🔹 Lấy token nếu có

      var response = await Dio().put(
        "https://fitting-solely-fawn.ngrok-free.app/api/Bill/UpdateBillStatus/${bill["id"]}",
        data:
            '"$newStatus"', // 🔹 API yêu cầu kiểu string nên phải đặt trong dấu ""
        options: Options(
          headers: {
            "Authorization": "Bearer $token", // 🔹 Nếu API yêu cầu token
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          bill["status"] =
              newStatus; // 🔄 Cập nhật UI sau khi thay đổi thành công
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Cập nhật trạng thái thành công!")),
        );
      } else {
        throw Exception("Lỗi cập nhật trạng thái");
      }
    } catch (e) {
      print("❌ Lỗi cập nhật trạng thái: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Cập nhật thất bại!")),
      );
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
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // ⏳ Hiển thị loading nếu đang tải
          : (allBills.isEmpty
              ? Center(
                  child: Text(
                      "Không có đơn hàng nào.")) // 🛑 Nếu không có đơn hàng
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(1), // Chờ xử lý
                    _buildOrderList(2), // Đang xử lý
                    _buildOrderList(3), // Đang giao
                    _buildOrderList(0), // Hoàn thành
                  ],
                )),
    );
  }

  /// ✅ **Hiển thị danh sách đơn hàng theo trạng thái**
  Widget _buildOrderList(int status) {
    List<dynamic> filteredBills =
        allBills.where((bill) => bill["status"] == status).toList();

    if (filteredBills.isEmpty) {
      return Center(child: Text("Không có đơn hàng nào."));
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchBills(currentShopId!),
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
                  Text(
                      "Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '').format(bill["total"])} VNĐ"),
                  Text(
                      "Ngày đặt: ${bill["receiveDate"] != null ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(bill["receiveDate"]) ?? DateTime.now()) : "Chưa có"}"),
                  Text(
                      "Giao hàng: ${bill["deliveryDate"] != null ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(bill["deliveryDate"]) ?? DateTime.now()) : "Chưa có"}"),
                  Text("Trạng thái: ${_getStatusText(bill["status"])}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.info, color: Colors.green),
                    onPressed: () {
                      _showOrderDetail(context, bill); // 🟢 Xem chi tiết
                    },
                  ),
                  if (status !=
                      0) // ❌ Ẩn nút chuyển trạng thái nếu đơn đã hoàn thành
                    IconButton(
                      icon: Icon(Icons.autorenew, color: Colors.blue),
                      onPressed: () {
                        _changeBillStatus(bill); // 🔄 Chuyển trạng thái
                      },
                    ),
                ],
              ),
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
              Text("Số lượng: ${bill["quantity"]}"),
              Text("Nội dung: ${bill["cakeContent"]}"),
              Text(
                  "Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '').format(bill["total"])} VNĐ"),
              Text(
                  "Giao hàng: ${bill["deliveryDate"] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(bill["deliveryDate"])) : "Chưa có"}"),
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

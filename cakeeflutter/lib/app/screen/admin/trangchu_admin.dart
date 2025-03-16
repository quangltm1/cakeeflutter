import 'package:cakeeflutter/app/core/base_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cakeeflutter/app/model/user.dart';

class TrangChuAdmin extends StatefulWidget {
  @override
  _TrangChuAdminState createState() => _TrangChuAdminState();
}

class _TrangChuAdminState extends State<TrangChuAdmin> {
  bool isLoading =
      true; // ✅ Biến trạng thái để kiểm tra có đang tải dữ liệu không
  String fullName = "Đang tải...";
  APIRepository apiRepository = APIRepository();
  List<dynamic> allBills = [];
  String? currentShopId;
  int completedOrders = 0;
  int pendingOrders = 0;
  int newOrders = 0;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _getShopIdAndFetchBills();
  }

  Future<void> _getShopIdAndFetchBills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? shopId = prefs.getString("userId");
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
    setState(() {
      isLoading = true;
    });

    try {
      var response = await Dio().get(
          "https://fitting-solely-fawn.ngrok-free.app/api/Bill/GetAllBill");

      if (response.statusCode == 200) {
        List<dynamic> bills = response.data;
        List<dynamic> shopBills =
            bills.where((bill) => bill["billShopId"] == shopId).toList();

        if (mounted) {
          setState(() {
            allBills = shopBills;
            completedOrders =
                shopBills.where((bill) => bill["status"] == 0).length;
            pendingOrders = shopBills
                .where((bill) => bill["status"] == 2 || bill["status"] == 3)
                .length;
            newOrders = shopBills.where((bill) => bill["status"] == 1).length;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("❌ Lỗi lấy danh sách đơn hàng: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      User? user = await apiRepository.current(token);
      if (mounted) {
        setState(() {
          fullName = user?.fullName ?? "Không có tên";
        });
      } else {
        setState(() {
          fullName = "Lỗi tải dữ liệu";
        });
      }
    } else {
      setState(() {
        fullName = "Chưa đăng nhập";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // ✅ Hiển thị vòng tròn loading
            : _buildContent(), // ✅ Hiển thị nội dung khi có dữ liệu
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Color(0xFFFFD900),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào, $fullName',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Cakee',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 150,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _buildStatCard(
                            'Đơn hoàn thành', '$completedOrders', Colors.green),
                        _buildStatCard('Đơn mới', '$newOrders', Colors.orange),
                        _buildStatCard(
                            'Đơn chưa xong', '$pendingOrders', Colors.blue),
                        _buildStatCard('Doanh thu', '0 đ', Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Danh sách chức năng
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 250,
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _buildFeatureButton(
                    features[index]["title"]!,
                    features[index]["icon"]!,
                    features[index]["color"]!,
                    () {
                      Navigator.pushNamed(context, features[index]["route"]!);
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Expanded(
              // Để tránh lỗi tràn ngang
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis), // Tránh lỗi tràn
                  Text(value,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis), // Tránh lỗi tràn
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis, // Tránh lỗi tràn
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> features = [
    {
      "title": "Bánh",
      "icon": Icons.cake,
      "color": Colors.blue,
      "route": "/cake"
    },
    {
      "title": "Danh mục",
      "icon": Icons.category,
      "color": Colors.green,
      "route": "/danh-muc"
    },
    {
      "title": "Phụ kiện",
      "icon": Icons.pan_tool,
      "color": Colors.red,
      "route": "/phu-kien"
    },
    {
      "title": "Size Bánh",
      "icon": Icons.format_size,
      "color": Colors.blue,
      "route": "/size-banh"
    },
    {
      "title": "Kho hàng",
      "icon": Icons.store,
      "color": Colors.orange,
      "route": "/kho-hang"
    },
  ];
}

import 'package:cakeeflutter/app/core/base_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cakeeflutter/app/model/user.dart';

class TrangChuAdmin extends StatefulWidget {
  @override
  _TrangChuAdminState createState() => _TrangChuAdminState();
}

class _TrangChuAdminState extends State<TrangChuAdmin> {
  int _totalRevenue = 0;
  bool _isLoading = true;

  DateTime? _startDate; // ✅ Thêm biến _startDate
  DateTime? _endDate;   // ✅ Thêm biến _endDate

  bool isLoading =
      true; // ✅ Biến trạng thái để kiểm tra có đang tải dữ liệu không
  String fullName = "Đang tải...";
  APIRepository apiRepository = APIRepository();
  List<dynamic> allBills = [];
  String? currentShopId;
  int completedOrders = 0;
  int pendingOrders = 0;
  int newOrders = 0;

  CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _getShopIdAndFetchBills();
  }

  @override
  void dispose() {
    _cancelToken.cancel(
        "Widget bị hủy, dừng request"); // 🔥 Hủy request khi widget bị dispose
    super.dispose();
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
  if (!mounted) return; // Kiểm tra widget có còn tồn tại không

  setState(() {
    isLoading = true;
  });

  try {
    var response = await Dio().get(
      "https://fitting-solely-fawn.ngrok-free.app/api/Bill/GetAllBill",
      cancelToken: _cancelToken,
    );

    if (response.statusCode == 200 && mounted) {
      List<dynamic> bills = response.data;

      // Lọc các bill hoàn thành trong tháng hiện tại
      DateTime now = DateTime.now();
      List<dynamic> shopBills = bills.where((bill) {
        DateTime billDate = DateTime.parse(bill["deliveryDate"]);
        return bill["billShopId"] == shopId &&
               bill["status"] == 0 && // Chỉ lấy bill hoàn thành
               billDate.year == now.year &&
               billDate.month == now.month;
      }).toList();

      double totalRevenue = 0;

      // Tính tổng doanh thu từ các bill hoàn thành
      for (var bill in shopBills) {
        try {
          totalRevenue += (bill["total"] as num).toDouble(); // Đảm bảo ép kiểu chính xác
        } catch (e) {
          print("❌ Lỗi khi đọc tổng tiền từ bill: $e");
        }
      }

      if (mounted) {
        setState(() {
          allBills = shopBills;
          completedOrders = shopBills.length;
          pendingOrders = bills.where((bill) => bill["status"] == 2 || bill["status"] == 3).length;
          newOrders = bills.where((bill) => bill["status"] == 1).length;
          _totalRevenue = totalRevenue.toInt(); // Ép kiểu về int để hiển thị dễ dàng
          isLoading = false;
        });
      }
    }
  } catch (e) {
    if (e is DioException && CancelToken.isCancel(e)) {
      print("⚠ Request đã bị hủy: $e");
    } else {
      print("❌ Lỗi lấy danh sách đơn hàng: $e");
    }
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
    }
  } else {
    if (mounted) {
      setState(() {
        fullName = "Chưa đăng nhập";
      });
    }
  }
}

// /// 🛠 **Hàm gọi API lấy doanh thu và số lượng bánh đã bán**
// Future<void> _fetchRevenueAndOrdersData(String shopId) async {
//   if (!mounted) return;

//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     var response = await Dio().get(
//       "https://fitting-solely-fawn.ngrok-free.app/api/Bill/GetAllBill",
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> bills = response.data;
//       double totalRevenue = 0.0;
//       int totalCakesSold = 0;
//       int completedOrders = 0;
//       int pendingOrders = 0;
//       int newOrders = 0;

//       DateTime now = DateTime.now();

//       // Lọc các bill của tháng hiện tại và shop hiện tại
//       List<dynamic> filteredBills = bills.where((bill) {
//         DateTime billDate = DateTime.parse(bill["deliveryDate"]);
//         bool isCurrentMonth = billDate.year == now.year && billDate.month == now.month;

//         return bill["billShopId"] == shopId && isCurrentMonth;
//       }).toList();

//       for (var bill in filteredBills) {
//         int status = bill["status"] as int;

//         if (status == 0) {
//           completedOrders++;
//           totalRevenue += (bill["total"] as num).toDouble();
//           totalCakesSold += (bill["quantity"] as num).toInt();
//         } else if (status == 1) {
//           newOrders++;
//         } else if (status == 2 || status == 3) {
//           pendingOrders++;
//         }
//       }

//       setState(() {
//         _totalRevenue = totalRevenue.toInt();
//         this.completedOrders = completedOrders;
//         this.pendingOrders = pendingOrders;
//         this.newOrders = newOrders;
//         _isLoading = false;
//       });
//     }
//   } catch (e) {
//     print("❌ Lỗi khi lấy dữ liệu: $e");
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    Text(
                    'Cakee',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    ),
                  ],
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                    return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final stats = [
                      {'title': 'Đơn hoàn thành', 'value': '$completedOrders'},
                      {'title': 'Đơn mới', 'value': '$newOrders'},
                      {'title': 'Đơn chưa xong', 'value': '$pendingOrders'},
                      {'title': 'Doanh thu', 'value': NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_totalRevenue)},
                      ];
                      return _buildStatCard(
                      stats[index]['title']!,
                      stats[index]['value']!,
                      index == 3 ? Colors.green : Colors.blue,
                      );
                    },
                    );
                  },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          
            // Danh sách chức năng
            Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                return _buildFeatureButton(
                  features[index]["title"] ?? "Unknown",
                  features[index]["icon"] ?? Icons.error,
                  features[index]["color"] ?? Colors.grey,
                  () {
                  Navigator.pushNamed(context, features[index]["route"] ?? "/");
                  },
                );
                },
              );
              },
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
          color: color.withAlpha((0.15 * 255).toInt()),
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
              backgroundColor: color.withAlpha((0.2 * 255).toInt()),
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

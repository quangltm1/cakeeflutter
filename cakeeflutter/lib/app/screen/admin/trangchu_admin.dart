import 'package:cakeeflutter/app/core/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cakeeflutter/app/model/user.dart';

class TrangChuAdmin extends StatefulWidget {
  @override
  _TrangChuAdminState createState() => _TrangChuAdminState();
}

class _TrangChuAdminState extends State<TrangChuAdmin> {
  String fullName = "Đang tải...";
  APIRepository apiRepository = APIRepository();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      User? user = await apiRepository.current(token);
      if (user != null) {
        setState(() {
          fullName = user.fullName ?? "Không có tên";
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Cakee',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        children: [
                          _buildStatCard('Đơn hoàn thành', '0',
                              Icons.shopping_cart, Colors.green),
                          _buildStatCard('Đơn chưa xong', '0',
                              Icons.pending_actions, Colors.orange),
                          _buildStatCard('Doanh thu', '0 đ', Icons.attach_money,
                              Colors.blue),
                          _buildStatCard('Khách hàng đã mua', '0',
                              Icons.people, Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Danh sách chức năng
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(value,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
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
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
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
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> features = [
    {"title": "Bánh", "icon": Icons.cake, "color": Colors.blue, "route": "/cake"},
    {"title": "Danh mục", "icon": Icons.category, "color": Colors.green, "route": "/danh-muc"},
    {"title": "Phụ kiện", "icon": Icons.pan_tool, "color": Colors.red, "route": "/phu-kien"},
    {"title": "Size Bánh", "icon": Icons.format_size, "color": Colors.blue, "route": "/size-banh"},
    {"title": "Kho hàng", "icon": Icons.store, "color": Colors.orange, "route": "/kho-hang"},
  ];
}

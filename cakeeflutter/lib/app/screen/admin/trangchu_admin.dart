import 'package:cakeeflutter/app/core/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cakeeflutter/app/model/user.dart';

class TrangChuAdmin extends StatefulWidget {
  @override
  _TrangChuAdminState createState() => _TrangChuAdminState();
}

class _TrangChuAdminState extends State<TrangChuAdmin> {
  String fullName = "Đang tải..."; // Giá trị mặc định
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
            mainAxisSize: MainAxisSize.min, // Ngăn lỗi tràn màn hình
            children: [
              // Header với tên người dùng động
              Container(
                padding: EdgeInsets.all(20),
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
                    Text(
                      'Xin chào, $fullName', // Hiển thị fullName lấy từ API
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Cakee',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Thống kê
              Padding(
                padding: EdgeInsets.all(10),
                child: GridView.count(
                  shrinkWrap: true, // Ngăn lỗi tràn màn hình
                  physics: NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn riêng
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  children: [
                    _buildStatCard('Đơn hàng đã bán', '0', Icons.shopping_cart),
                    _buildStatCard('Doanh thu bán hàng', '0 đ', Icons.monetization_on),
                    _buildStatCard('Khách đã mua hàng', '0', Icons.people),
                    _buildStatCard('Công nợ khách hàng', '0 đ', Icons.receipt),
                  ],
                ),
              ),

              // Chức năng
              Padding(
                padding: EdgeInsets.all(10),
                child: GridView.count(
                  shrinkWrap: true, // Ngăn lỗi tràn màn hình
                  physics: NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn riêng
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  children: [
                    _buildFeatureButton('Bánh', Icons.shopping_bag, Colors.blue, () {
                      Navigator.pushNamed(context, '/cake'); // Chuyển đến màn hình sản phẩm
                    }),
                    _buildFeatureButton('Danh mục bánh', Icons.category, Colors.green, () {
                      Navigator.pushNamed(context, '/danh-muc'); // Chuyển đến màn hình khách hàng
                    }),
                    _buildFeatureButton('Đơn hàng', Icons.receipt, Colors.red, () {
                      Navigator.pushNamed(context, '/don-hang'); // Chuyển đến màn hình đơn hàng
                    }),
                    _buildFeatureButton('Báo cáo', Icons.bar_chart, Colors.blue, () {
                      Navigator.pushNamed(context, '/bao-cao'); // Chuyển đến màn hình báo cáo
                    }),
                    _buildFeatureButton('Kho hàng', Icons.store, Colors.orange, () {
                      Navigator.pushNamed(context, '/kho-hang'); // Chuyển đến màn hình kho hàng
                    }),
                  ],
                ),
              ),

              // Thêm khoảng trống cuối để tránh lỗi tràn
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Color(0xFFFFD900)),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
      String title, IconData icon, Color color, VoidCallback onPress) {
    return GestureDetector(
      onTap: onPress, // Bắt sự kiện nhấn vào
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

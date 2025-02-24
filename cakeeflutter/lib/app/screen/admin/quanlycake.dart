import 'package:cakeeflutter/app/model/cake.dart';
import 'package:cakeeflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'cake_details.dart'; // ✅ Import trang chi tiết bánh

class QuanLyCake extends StatefulWidget {
  @override
  _CakeListScreenState createState() => _CakeListScreenState();
}

class _CakeListScreenState extends State<QuanLyCake> with RouteAware {
  late Future<List<Cake>> futureCakes;

  @override
  void initState() {
    super.initState();
    futureCakes = Future.value([]); // ✅ Tránh lỗi null
    _loadCakes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off and the user returns to this route.
    _loadCakes();
  }

  Future<void> _loadCakes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    print("📌 Debug từ SharedPreferences: UserID = $userId, Token = $token");

    if (userId == null) {
      print("❌ Lỗi: Không tìm thấy userId trong SharedPreferences");
      return;
    }

    if (token == null) {
      print("❌ Lỗi: Token không tồn tại, người dùng có thể chưa đăng nhập.");
      return;
    }

    try {
      Future<List<Cake>> fetchedCakes =
          APIRepository().fetchCakesByUserId(userId);

      fetchedCakes.then((cakes) {
        print("✅ Lấy danh sách bánh thành công, tổng số: ${cakes.length}");
      }).catchError((error) {
        print("❌ Lỗi khi tải danh sách bánh: $error");
      });

      setState(() {
        futureCakes = fetchedCakes;
      });
    } catch (e) {
      print("❌ Lỗi khi tải danh sách bánh: $e");
    }
  }

  /// ✅ Hiển thị popup xác nhận trước khi xóa
  void _showDeleteConfirmationDialog(String cakeId) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng khi nhấn bên ngoài
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning,
                    color: Colors.red, size: 40), // Icon cảnh báo
                SizedBox(height: 10),
                Text(
                  "Xác nhận xóa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Bạn có chắc chắn muốn xóa bánh này?\nHành động này không thể hoàn tác!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () =>
                            Navigator.of(context).pop(), // Đóng popup
                        child:
                            Text("Hủy", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng popup
                          _deleteCake(cakeId); // ✅ Thực hiện xóa
                        },
                        child:
                            Text("Xóa", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ Hàm xóa bánh
  Future<void> _deleteCake(String cakeId) async {
    try {
      bool success = await APIRepository().deleteCake(cakeId);
      if (success) {
        print("✅ Xóa bánh thành công: $cakeId");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Xóa bánh thành công!")));
        _loadCakes(); // Tải lại danh sách sau khi xóa
      } else {
        print("❌ Lỗi khi xóa bánh");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Lỗi khi xóa bánh!")));
      }
    } catch (e) {
      print("❌ Lỗi khi xóa bánh: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Bánh'),
        backgroundColor: Color(0xFFFFD900),
      ),
      body: FutureBuilder<List<Cake>>(
        future: futureCakes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("❌ Lỗi từ API: ${snapshot.error}");
            return Center(
                child: Text('Lỗi khi tải danh sách bánh: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('Không có bánh nào được tìm thấy.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Cake cake = snapshot.data![index];

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCakeScreen(
                            cake: cake), // ✅ Chuyển đến chi tiết bánh
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _getValidImageUrl(cake.cakeImage),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey);
                      },
                    ),
                  ),
                  title: Text(cake.cakeName),
                  subtitle: Text(cake.cakeDescription),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(cake.id),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  /// ✅ Hàm kiểm tra URL ảnh hợp lệ
  String _getValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return "https://via.placeholder.com/150"; // Ảnh mặc định nếu URL bị null hoặc rỗng
    }

    Uri? uri = Uri.tryParse(imageUrl);
    if (uri != null && (uri.scheme == "http" || uri.scheme == "https")) {
      if (uri.host.contains("google.com") || uri.host.contains("imgres")) {
        print("❌ URL không hợp lệ: $imageUrl");
        return "https://via.placeholder.com/150"; // Tránh URL từ Google Search
      }
      return imageUrl;
    } else {
      return "https://via.placeholder.com/150"; // Ảnh thay thế nếu URL không hợp lệ
    }
  }
}

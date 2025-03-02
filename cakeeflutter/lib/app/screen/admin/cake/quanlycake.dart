import 'dart:math';
import 'package:cakeeflutter/app/model/cake.dart';
import 'package:cakeeflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service.dart';
import 'cake_details.dart';

class QuanLyCake extends StatefulWidget {
  @override
  _CakeListScreenState createState() => _CakeListScreenState();
}

class _CakeListScreenState extends State<QuanLyCake> with RouteAware {
  late Future<List<Cake>> futureCakes;

  @override
  void initState() {
    super.initState();
    futureCakes = Future.value([]);
    _loadCakes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(
        this, ModalRoute.of(context)! as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadCakes(); // 🔥 Khi quay lại từ trang khác, reload dữ liệu
  }

  Future<void> _loadCakes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      print("❌ Không tìm thấy userId");
      return;
    }

    try {
      setState(() {
        futureCakes = APIRepository().fetchCakesByUserId(userId);
      });
    } catch (e) {
      print("❌ Lỗi khi tải danh sách bánh: $e");
    }
  }

  void _deleteCake(String cakeId) async {
    bool success = await APIRepository().deleteCake(cakeId);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("✅ Xóa bánh thành công!")));
      _loadCakes();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Lỗi khi xóa bánh!")));
    }
  }

  /// ✅ **Tạo ObjectId mới giống MongoDB (24 ký tự hex)**
  String _generateObjectId() {
    final Random random = Random.secure();
    const String hexChars = "0123456789abcdef";
    return List.generate(24, (index) => hexChars[random.nextInt(16)]).join();
  }

  void _confirmDeleteCake(String cakeId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa bánh này không?"),
        actions: [
          TextButton(
            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
          ),
          TextButton(
            child: Text("Xóa", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại trước khi xóa
              _deleteCake(cakeId); // Gọi hàm xóa bánh
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Quản Lý Bánh'), backgroundColor: Colors.amber),
      body: FutureBuilder<List<Cake>>(
        future: futureCakes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('Không có bánh nào được tìm thấy.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Cake cake = snapshot.data![index];

                return Card(
                  elevation: 4, // Hiệu ứng đổ bóng
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _getValidImageUrl(cake.cakeImage),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cake.cakeName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                cake.cakeDescription,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    cake.cakeRating.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${cake.cakePrice.toStringAsFixed(0)} VND",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditCakeScreen(cake: cake),
                                  ),
                                ).then((_) => _loadCakes());
                              },
                              child: Icon(Icons.edit, color: Colors.blue),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _confirmDeleteCake(cake.id),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.delete, color: Colors.white),
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? userId = prefs.getString('userId');

          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ Lỗi: Không tìm thấy User ID!")));
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditCakeScreen(
                      cake: Cake(
                        id: "", // ❌ Không tự động tạo ID mới, để API tự xử lý
                        cakeName: '',
                        cakeSize: 0,
                        cakeDescription: '',
                        cakePrice: 0.0,
                        cakeImage: '',
                        cakeRating: 0.0,
                        cakeStock: 0,
                        cakeCategoryId: '',
                        userId: userId,
                      ),
                    )),
          ).then((_) => _loadCakes()); // 🔥 Reload danh sách bánh sau khi thêm
        },
        child: Icon(Icons.add, size: 28),
      ),
    );
  }

  String _getValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return "https://via.placeholder.com/150";
    }
    Uri? uri = Uri.tryParse(imageUrl);
    return (uri != null && (uri.scheme == "http" || uri.scheme == "https"))
        ? imageUrl
        : "https://via.placeholder.com/150";
  }
}

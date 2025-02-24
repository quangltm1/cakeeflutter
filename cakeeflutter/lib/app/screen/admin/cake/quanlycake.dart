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
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute<dynamic>);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Xóa bánh thành công!")));
      _loadCakes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Lỗi khi xóa bánh!")));
    }
  }

  /// ✅ **Tạo ObjectId mới giống MongoDB (24 ký tự hex)**
  String _generateObjectId() {
    final Random random = Random.secure();
    const String hexChars = "0123456789abcdef";
    return List.generate(24, (index) => hexChars[random.nextInt(16)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản Lý Bánh'), backgroundColor: Colors.amber),
      body: FutureBuilder<List<Cake>>(
        future: futureCakes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
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
                      MaterialPageRoute(builder: (context) => EditCakeScreen(cake: cake)),
                    ).then((_) => _loadCakes()); // 🔥 Reload khi chỉnh sửa xong
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _getValidImageUrl(cake.cakeImage),
                      width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                  title: Text(cake.cakeName),
                  subtitle: Text(cake.cakeDescription),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCake(cake.id),
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
          String? userId = prefs.getString('userId'); // 🔥 Lấy userId từ SharedPreferences

          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Lỗi: Không tìm thấy User ID!")));
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditCakeScreen(
              cake: Cake(
                id: _generateObjectId(), // 🔥 ID mới theo chuẩn ObjectId
                cakeName: '',
                cakeSize: 0,
                cakeDescription: '',
                cakePrice: 0.0,
                cakeImage: '',
                cakeRating: 0.0,
                cakeStock: 0,
                cakeCategoryId: '',
                userId: userId, // ✅ Gán đúng userId của người dùng hiện tại
              ),
            )),
          ).then((_) => _loadCakes()); // 🔥 Khi quay lại, load lại danh sách bánh
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
    return (uri != null && (uri.scheme == "http" || uri.scheme == "https")) ? imageUrl : "https://via.placeholder.com/150";
  }
}

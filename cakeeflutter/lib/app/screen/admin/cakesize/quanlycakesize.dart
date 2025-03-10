import 'package:cakeeflutter/app/model/cakesize.dart';
import 'package:cakeeflutter/app/screen/admin/cakesize/cakesize_details.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base_service.dart';

class QuanLyCakeSize extends StatefulWidget {
  @override
  _QuanLyCakeSizeState createState() => _QuanLyCakeSizeState();
}

class _QuanLyCakeSizeState extends State<QuanLyCakeSize> {
  late Future<List<CakeSize>> _futureCakeSizes = Future.value([]);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCakeSizes();
  }

  void _loadCakeSizes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      print("❌ Không tìm thấy User ID!");
      return;
    }

    setState(() {
      _isLoading = true;
      _futureCakeSizes = APIRepository().fetchCakeSizesByUserId(userId);
    });

    _futureCakeSizes.whenComplete(() => setState(() => _isLoading = false));
  }

  void _confirmDeleteCakeSize(String cakeSizeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text("Xác nhận xóa", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("Bạn có chắc chắn muốn xóa Cake Size này không?"),
          actions: [
            TextButton(
              child: Text("Hủy", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCakeSize(cakeSizeId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCakeSize(String cakeSizeId) async {
    setState(() => _isLoading = true);
    bool success = await APIRepository().deleteCakeSize(cakeSizeId);
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "✅ Xóa Cake Size thành công" : "❌ Xóa Cake Size thất bại"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) _loadCakeSizes();
  }

  void _addOrUpdateCakeSize([String? cakeSizeId]) async {
  print("📌 Chuyển đến CakeSizeDetailScreen với ID: $cakeSizeId");
  bool? updated = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CakeSizeDetailScreen(cakeSizeId: cakeSizeId)),
  );

  if (updated == true) _loadCakeSizes();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản Lý Cake Size'), backgroundColor: Colors.amber),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<CakeSize>>(
              future: _futureCakeSizes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Chưa có Cake Size nào"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Chưa có Cake Size nào"));
                }

                List<CakeSize> cakeSizes = snapshot.data!;

                return ListView.builder(
                  itemCount: cakeSizes.length,
                  itemBuilder: (context, index) {
                    final cakeSize = cakeSizes[index];

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber.shade100,
                          child: Icon(Icons.cake, color: Colors.amber.shade700),
                        ),
                        title: Text(
                          cakeSize.sizeName ?? "Không có tên",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteCakeSize(cakeSize.id),
                        ),
                        onTap: () => _addOrUpdateCakeSize(cakeSize.id),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateCakeSize(),
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }
}

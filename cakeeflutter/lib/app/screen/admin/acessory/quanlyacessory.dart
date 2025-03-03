import 'package:cakeeflutter/app/model/acessory.dart';
import 'package:cakeeflutter/app/screen/admin/acessory/acessory_details.dart';
import 'package:cakeeflutter/app/screen/admin/category/category_details.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service.dart';

class QuanLyAcessory extends StatefulWidget {
  @override
  _QuanLyAcessoryState createState() => _QuanLyAcessoryState();
}

class _QuanLyAcessoryState extends State<QuanLyAcessory> {
  late Future<List<Acessory>> _futureAcessories = Future.value([]);

  @override
  void initState() {
    super.initState();
    _loadAcessories();
  }

  void _loadAcessories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      print("❌ Không tìm thấy User ID!");
      return;
    }

    print("📌 Gọi API lấy danh mục với userId: $userId");

    setState(() {
      _futureAcessories = APIRepository().fetchAcessoriesByUserId(userId);
    });
  }

  void _confirmDeleteAcessory(String acessoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text("Xác nhận xóa"),
            ],
          ),
          content: Text("Bạn có chắc chắn muốn xóa phụ kiện này không?"),
          actions: [
            TextButton(
              child: Text("Hủy", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Xóa", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAcessory(acessoryId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAcessory(String acessoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Không tìm thấy User ID!")),
      );
      return;
    }

    bool success = await APIRepository().deleteAcessory(acessoryId);
    if (success) {
      setState(() {
        _futureAcessories = APIRepository().fetchAcessoriesByUserId(userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Xóa phụ kiện thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Xóa phụ kiện thất bại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Quản Lý Phụ Kiện'), backgroundColor: Colors.amber),
      body: FutureBuilder<List<Acessory>>(
        future: _futureAcessories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Chưa có phụ kiện nào"));
          }

          List<Acessory> acessories = snapshot.data!;

          return ListView.builder(
            itemCount: acessories.length,
            itemBuilder: (context, index) {
              final acessory = acessories[index];

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    child: Icon(Icons.pan_tool, color: Colors.amber.shade700),
                  ),
                  title: Text(
                    acessory.acessoryName.toString() ?? "Không có tên",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteAcessory(acessory.id),
                  ),
                  onTap: () async {
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AcessoryDetailScreen(acessoryId: acessory.id),
                      ),
                    );

                    // Nếu phụ kiện được cập nhật, load lại danh sách
                    if (updated == true) {
                      _loadAcessories();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }
}

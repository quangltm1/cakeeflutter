import 'package:cakeeflutter/app/screen/admin/category/category_details.dart';
import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/model/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base_service.dart';

class QuanLyCategory extends StatefulWidget {
  @override
  _QuanLyCategoryState createState() => _QuanLyCategoryState();
}

class _QuanLyCategoryState extends State<QuanLyCategory> {
  late Future<List<Category>> _futureCategories = Future.value([]);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      print("❌ Không tìm thấy User ID!");
      return;
    }

    print("📌 Gọi API lấy danh mục với userId: $userId");

    setState(() {
      _futureCategories = APIRepository().getCategoryByUserID(userId);
    });
  }

  void _confirmDeleteCategory(String categoryId) {
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
          content: Text("Bạn có chắc chắn muốn xóa danh mục này không?"),
          actions: [
            TextButton(
              child: Text("Hủy", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Xóa", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategory(categoryId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(String categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Không tìm thấy User ID!")),
      );
      return;
    }

    bool success = await APIRepository().deleteCategory(categoryId);
    if (success) {
      setState(() {
        _futureCategories = APIRepository().getCategoryByUserID(userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Xóa danh mục thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Xóa danh mục thất bại")),
      );
    }
  }

  void _addOrUpdateCategory([String? categoryId]) async {
  bool? updated = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CategoryDetailScreen(categoryId: categoryId ?? ''),
    ),
  );

  if (updated == true) {
    _loadCategories();
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Category'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<List<Category>>(
        future: _futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Chưa có danh mục nào"));
          }

          List<Category> categories = snapshot.data!;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    child: Icon(Icons.category, color: Colors.amber.shade700),
                  ),
                  title: Text(
                    category.categoryName ?? "Không có tên",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteCategory(category.id),
                  ),
                  onTap: () => _addOrUpdateCategory(category.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateCategory(),
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }
}

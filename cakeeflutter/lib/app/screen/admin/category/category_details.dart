import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/model/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base_service.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;

  CategoryDetailScreen({required this.categoryId});

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  Category? _category;
  bool _isLoading = true;
  TextEditingController _categoryNameController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    if (widget.categoryId.isNotEmpty) {
      _fetchCategory();
    } else {
      _isLoading = false; // Nếu tạo mới, không cần load dữ liệu
    }
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _fetchCategory() async {
    try {
      var category = await APIRepository().getCategoryById(widget.categoryId);
      if (category != null) {
        setState(() {
          _category = category;
          _categoryNameController.text = category.categoryName ?? "";
          _isLoading = false;
        });
      } else {
        setState(() {
          _category = null;
          _isLoading = false;
        });
      }
    } catch (error) {
      print("❌ Lỗi khi lấy danh mục: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveCategory() async {
  if (_categoryNameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Vui lòng nhập tên danh mục")),
    );
    return;
  }

  setState(() => _isLoading = true);

  bool success;
  if (widget.categoryId.isEmpty) {
    // Nếu categoryId rỗng -> Thêm mới
    success = await APIRepository().addCategory(_categoryNameController.text);
  } else {
    // Nếu có categoryId -> Cập nhật
    success = await APIRepository().updateCategory(
      widget.categoryId, 
      _categoryNameController.text
    );
  }

  setState(() => _isLoading = false);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.categoryId.isEmpty ? "✅ Tạo danh mục thành công" : "✅ Cập nhật danh mục thành công"))
    );
    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ ${widget.categoryId.isEmpty ? "Tạo" : "Cập nhật"} danh mục thất bại"))
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryId.isEmpty ? 'Thêm Danh Mục' : 'Chi Tiết Danh Mục')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tên danh mục:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nhập tên danh mục",
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: Text(widget.categoryId.isEmpty ? "Tạo mới" : "Cập nhật"),
                  ),
                ],
              ),
            ),
    );
  }
}

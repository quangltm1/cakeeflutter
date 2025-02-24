import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/model/cake.dart';
import 'package:cakeeflutter/app/model/category.dart';
import '../../core/api_service.dart';

class EditCakeScreen extends StatefulWidget {
  final Cake cake;

  EditCakeScreen({required this.cake});

  @override
  _EditCakeScreenState createState() => _EditCakeScreenState();
}

class _EditCakeScreenState extends State<EditCakeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;

  List<Category> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.cake.cakeName);
    _descriptionController =
        TextEditingController(text: widget.cake.cakeDescription);
    _priceController =
        TextEditingController(text: widget.cake.cakePrice.toString());
    _stockController =
        TextEditingController(text: widget.cake.cakeStock.toString());
    _imageController = TextEditingController(text: widget.cake.cakeImage ?? "");

    _selectedCategoryId = widget.cake.cakeCategoryId;

    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _loadCategories() async {
    try {
      List<Category> categories = await APIRepository().fetchCategories();
      setState(() {
        _categories = categories;

        // Kiểm tra nếu danh mục hiện tại không có trong danh sách
        bool isValidCategory =
            _categories.any((c) => c.id == _selectedCategoryId);
        if (!isValidCategory) {
          _selectedCategoryId = null;
        }
      });
    } catch (e) {
      print("❌ Lỗi khi lấy danh mục: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa bánh")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hình ảnh:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Image.network(
                _imageController.text.isNotEmpty
                    ? _imageController.text
                    : "https://via.placeholder.com/200",
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported,
                      size: 100, color: Colors.grey);
                },
              ),
              TextField(
                controller: _imageController,
                decoration: InputDecoration(labelText: "URL Hình ảnh"),
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Tên bánh"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Mô tả"),
                maxLines: 3,
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Giá (VND)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _stockController,
                decoration: InputDecoration(labelText: "Số lượng tồn kho"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text("Danh mục bánh:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _categories.isEmpty
                  ? CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _categories.any((c) => c.id == _selectedCategoryId)
                          ? _selectedCategoryId
                          : null,
                      decoration: InputDecoration(labelText: "Danh mục"),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.categoryName.isNotEmpty
                              ? category.categoryName
                              : "Không có tên"),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategoryId = newValue;
                        });
                      },
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text("Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    try {
      Map<String, dynamic> updateData = {};

      String newDescription = _descriptionController.text.trim();

      print("📌 New Description: $newDescription"); // Debug giá trị mới

      if (newDescription.isNotEmpty &&
          newDescription != widget.cake.cakeDescription) {
        updateData["CakeDescription"] = newDescription;
      }

      if (updateData.isEmpty) {
        print("⚠️ Không có thay đổi nào để cập nhật!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Không có thay đổi nào để cập nhật!")),
        );
        return;
      }

      print("📌 Data gửi lên API: $updateData"); // Debug

      bool success =
          await APIRepository().updateCake(widget.cake.id, updateData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Cập nhật thành công!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Cập nhật thất bại!")),
        );
      }
    } catch (e) {
      print("❌ Lỗi khi cập nhật: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi khi cập nhật: $e")),
      );
    }
  }
}

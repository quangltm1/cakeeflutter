import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/model/cake.dart';
import 'package:cakeeflutter/app/model/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base_service.dart';

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
  bool _isLoading = false;

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

  void _loadCategories() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      print("❌ Không tìm thấy User ID!");
      return;
    }


    List<Category> categories = await APIRepository().getCategoryByUserID(userId);

    setState(() {
      _categories = categories;
      bool isValidCategory = _categories.any((c) => c.id == _selectedCategoryId);
      if (!isValidCategory) {
        _selectedCategoryId = null;
      }
    });

  } catch (e) {
    print("❌ Lỗi khi lấy danh mục: $e");
  }
}


  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Không tìm thấy User ID!")),
        );
        return;
      }

      // Kiểm tra kiểu dữ liệu
      print("📌 userId: $userId (${userId.runtimeType})");
      print(
          "📌 cakeCategoryId: $_selectedCategoryId (${_selectedCategoryId.runtimeType})");

      Map<String, dynamic> cakeData = {
        "cakeName": _nameController.text.trim(),
        "cakeDescription": _descriptionController.text.trim(),
        "cakePrice": double.tryParse(_priceController.text.trim()) ?? 0.0,
        "cakeQuantity": int.tryParse(_stockController.text.trim()) ?? 0,
        "cakeImage": _imageController.text.trim(),
        "cakeCategoryId": _selectedCategoryId ?? "",
        "userId": userId,
      };


      bool success;
      if (widget.cake.id.isNotEmpty) {
        success = await APIRepository().updateCake(widget.cake.id, cakeData);
      } else {
        success = await APIRepository().createCake(cakeData);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cake.id.isNotEmpty
                ? "✅ Cập nhật thành công!"
                : "✅ Đã tạo bánh mới!"),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Thao tác thất bại!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi khi xử lý: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.cake.id.isNotEmpty ? "Chỉnh sửa bánh" : "Tạo bánh mới"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
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
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(_imageController, "URL Hình ảnh"),
              SizedBox(height: 20),
              _buildTextField(_nameController, "Tên bánh"),
              _buildTextField(_descriptionController, "Mô tả", maxLines: 3),
              _buildTextField(_priceController, "Giá (VND)", isNumber: true),
              _buildTextField(_stockController, "Số lượng tồn kho",
                  isNumber: true),
              SizedBox(height: 20),
              Text("Danh mục bánh:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _categories.isEmpty
                  ? CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), filled: true),
                      menuMaxHeight: 300,
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
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _saveChanges,
                      label:
                          Text("Lưu thay đổi", style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label, border: OutlineInputBorder(), filled: true),
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}

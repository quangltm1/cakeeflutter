import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/model/cake.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cake.cakeName);
    _descriptionController = TextEditingController(text: widget.cake.cakeDescription);
    _priceController = TextEditingController(text: widget.cake.cakePrice.toString());
    _stockController = TextEditingController(text: widget.cake.cakeStock.toString());
    _imageController = TextEditingController(text: widget.cake.cakeImage ?? "");
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
                _imageController.text.isNotEmpty ? _imageController.text : "https://via.placeholder.com/200",
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
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
              ElevatedButton(
                onPressed: () {
                  _saveChanges();
                },
                child: Text("Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    Cake updatedCake = Cake(
      id: widget.cake.id,
      cakeName: _nameController.text,
      cakeDescription: _descriptionController.text,
      cakePrice: double.parse(_priceController.text),
      cakeStock: int.parse(_stockController.text),
      cakeImage: _imageController.text,
      cakeSize: widget.cake.cakeSize,
      cakeRating: widget.cake.cakeRating,
      cakeCategoryId: widget.cake.cakeCategoryId,
      userId: widget.cake.userId,
    );

    try {
      bool success = await APIRepository().updateCake(widget.cake.id, updatedCake);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Thông tin bánh đã được cập nhật!")),
        );
        Navigator.pop(context, true); // Quay về trang quản lý bánh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi cập nhật bánh!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật: $e")),
      );
    }
  }
}

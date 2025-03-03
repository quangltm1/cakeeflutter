import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base_service.dart';

class CakeSizeDetailScreen extends StatefulWidget {
  final String? cakeSizeId;

  CakeSizeDetailScreen({this.cakeSizeId});

  @override
  _CakeSizeDetailScreenState createState() => _CakeSizeDetailScreenState();
}

class _CakeSizeDetailScreenState extends State<CakeSizeDetailScreen> {
  TextEditingController _sizeNameController = TextEditingController();
  bool _isLoading = false;
  String? _userId;

  @override
void initState() {
  super.initState();
  _loadUserId(); // ⚡ Load userId ngay khi vào màn hình
  print("📌 Đang vào CakeSizeDetailScreen với ID: ${widget.cakeSizeId}");
  if (widget.cakeSizeId != null) {
    _fetchCakeSize();
  }
}

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _fetchCakeSize() async {
    setState(() => _isLoading = true);
    var cakeSize = await APIRepository().getCakeSizeById(widget.cakeSizeId!);
    if (cakeSize != null) {
      setState(() {
        _sizeNameController.text = cakeSize.sizeName;
      });
    }
    setState(() => _isLoading = false);
  }

  void _saveCakeSize() async {
  String newSizeName = _sizeNameController.text.trim();
  if (newSizeName.isEmpty || _userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("⚠️ Vui lòng nhập tên kích thước và đảm bảo đã đăng nhập")),
    );
    return;
  }

  setState(() => _isLoading = true);
  bool success;

  if (widget.cakeSizeId != null) {
    print("📌 Gửi update với ID: ${widget.cakeSizeId}");
    success = await APIRepository().updateCakeSize(widget.cakeSizeId!, newSizeName);
  } else {
    print("📌 Tạo Cake Size mới với ID rỗng ('') và tên: $newSizeName");
    success = await APIRepository().createCakeSize(newSizeName, _userId!);
  }

  setState(() => _isLoading = false);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(success ? "✅ Thành công" : "❌ Thất bại")),
  );

  if (success) Navigator.pop(context, true);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.cakeSizeId == null
              ? 'Thêm Size Bánh'
              : 'Chi Tiết Size Bánh')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tên Size:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(
                      controller: _sizeNameController,
                      decoration:
                          InputDecoration(border: OutlineInputBorder())),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveCakeSize,
                    child: Text(
                        widget.cakeSizeId == null ? "Tạo mới" : "Cập nhật"),
                  ),
                ],
              ),
            ),
    );
  }
}

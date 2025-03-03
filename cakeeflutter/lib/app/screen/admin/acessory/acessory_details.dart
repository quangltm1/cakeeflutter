import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/model/acessory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base_service.dart';

class AcessoryDetailScreen extends StatefulWidget {
  final String? acessoryId;

  AcessoryDetailScreen({this.acessoryId});

  @override
  _AcessoryDetailScreenState createState() => _AcessoryDetailScreenState();
}

class _AcessoryDetailScreenState extends State<AcessoryDetailScreen> {
  Acessory? _acessory;
  bool _isLoading = false;
  TextEditingController _acessoryNameController = TextEditingController();
  TextEditingController _acessoryPriceController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    if (widget.acessoryId != null) {
      _fetchAcessory();
    }
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _fetchAcessory() async {
    setState(() => _isLoading = true);
    var acessory = await APIRepository().getAcessoryById(widget.acessoryId!);
    if (acessory != null) {
      setState(() {
        _acessory = acessory;
        _acessoryNameController.text = acessory.acessoryName;
        _acessoryPriceController.text = acessory.acessoryPrice.toString();
      });
    }
    setState(() => _isLoading = false);
  }

  void _saveAcessory() async {
    String name = _acessoryNameController.text.trim();
    double? price = double.tryParse(_acessoryPriceController.text.trim());

    if (name.isEmpty || price == null || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success;

    if (widget.acessoryId != null) {
      success = await APIRepository().updateAcessory(widget.acessoryId!, name, price);
    } else {
      success = await APIRepository().createAcessory(name, price, _userId!);
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
      appBar: AppBar(title: Text(widget.acessoryId == null ? 'Thêm Phụ Kiện' : 'Chi Tiết Phụ Kiện')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tên phụ kiện:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(controller: _acessoryNameController, decoration: InputDecoration(border: OutlineInputBorder())),
                  SizedBox(height: 16),
                  Text("Giá phụ kiện:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(controller: _acessoryPriceController, keyboardType: TextInputType.number, decoration: InputDecoration(border: OutlineInputBorder())),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: _saveAcessory, child: Text(widget.acessoryId == null ? "Tạo mới" : "Cập nhật")),
                ],
              ),
            ),
    );
  }
}
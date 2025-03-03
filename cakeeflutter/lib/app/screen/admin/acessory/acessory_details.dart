import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/model/acessory.dart';
import '../../../core/api_service.dart';

class AcessoryDetailScreen extends StatefulWidget {
  final String acessoryId;

  AcessoryDetailScreen({required this.acessoryId});

  @override
  _AcessoryDetailScreenState createState() => _AcessoryDetailScreenState();
}

class _AcessoryDetailScreenState extends State<AcessoryDetailScreen> {
  Acessory? _acessory;
  bool _isLoading = true;
  TextEditingController _acessoryNameController = TextEditingController();
  TextEditingController _acessoryPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _acessoryNameController = TextEditingController(); // Khởi tạo controller
    _acessoryPriceController = TextEditingController(); // Khởi tạo controller
    _fetchAcessory(); // Gọi _fetchAcessory khi khởi tạo
  }

  Future<void> _fetchAcessory() async {
    try {
      print("📌 Gọi API lấy phụ kiện với acessoryId: ${widget.acessoryId}");

      var acessory = await APIRepository().getAcessoryById(widget.acessoryId);

      if (acessory != null) {
        print("📌 Acessory nhận từ API: ${acessory.acessoryName}");
        setState(() {
          _acessory = acessory; // Cập nhật trạng thái _acessory
          _acessoryNameController.text = acessory.acessoryName.toString() ?? "Không có tên";
          _acessoryPriceController.text = acessory.acessoryPrice.toString(); // Hiển thị giá trị số nguyên
          _isLoading = false; // Cập nhật trạng thái _isLoading
        });
      } else {
        print("⚠️ Không tìm thấy phụ kiện!");
        setState(() {
          _acessory = null; // Cập nhật trạng thái _acessory
          _acessoryNameController.text = "Không tìm thấy";
          _isLoading = false; // Cập nhật trạng thái _isLoading
        });
      }
    } catch (error) {
      print("❌ Lỗi khi lấy phụ kiện: $error");
      setState(() {
        _isLoading = false; // Cập nhật trạng thái _isLoading
      });
    }
  }

  void _updateAcessory() async {
    if (_acessory == null) return;

    setState(() {
      _isLoading = true;
    });

    bool success = await APIRepository().updateAcessory(
  widget.acessoryId,
  {
    "acessoryName": _acessoryNameController.text,
    "acessoryPrice": double.tryParse(_acessoryPriceController.text) ?? 0.0,
  },
);


    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Cập nhật thành công")),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Cập nhật thất bại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi Tiết Phụ Kiện')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _acessory == null
              ? Center(child: Text("Không tìm thấy phụ kiện"))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tên phụ kiện:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _acessoryNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Nhập tên phụ kiện",
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Giá phụ kiện:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _acessoryPriceController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Nhập giá phụ kiện",
                        ),
                        keyboardType: TextInputType.number, // Đặt bàn phím số
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updateAcessory,
                        child: Text("Cập nhật"),
                      ),
                    ],
                  ),
                ),
    );
  }
}

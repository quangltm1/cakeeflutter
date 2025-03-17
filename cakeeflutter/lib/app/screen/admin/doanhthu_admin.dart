import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // Để format ngày tháng

class DoanhthuAdmin extends StatefulWidget {
  @override
  _DoanhthuAdminState createState() => _DoanhthuAdminState();
}

class _DoanhthuAdminState extends State<DoanhthuAdmin> {
  int _totalRevenue = 0;
  int _totalCakesSold = 0;
  bool _isLoading = true;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchRevenueData(); // Gọi API khi vào màn hình
  }

  /// 🛠 **Hàm chọn ngày**
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate =
        isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  /// 🛠 **Gọi API lấy doanh thu & số lượng bánh đã bán**
  Future<void> _fetchRevenueData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var response = await Dio().get(
          "https://fitting-solely-fawn.ngrok-free.app/api/Bill/GetAllBill");

      if (response.statusCode == 200) {
        List<dynamic> bills = response.data;
        double revenue = 0.0;
        double cakesSold = 0.0;

        for (var bill in bills) {
          if (bill["status"] == 0) {
            // Chỉ tính đơn đã hoàn thành
            DateTime billDate = DateTime.parse(bill["deliveryDate"]);

            // Nếu có lọc theo ngày
            if (_startDate != null && _endDate != null) {
              if (billDate.isBefore(_startDate!) ||
                  billDate.isAfter(_endDate!)) {
                continue; // Bỏ qua đơn hàng không nằm trong khoảng thời gian
              }
            }

            revenue += (bill["total"] as num).toDouble();
            cakesSold += (bill["quantity"] as num).toDouble();
          }
        }

        setState(() {
          _totalRevenue = revenue.toInt();
          _totalCakesSold = cakesSold.toInt();

          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Lỗi lấy doanh thu: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doanh Thu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFFFD900),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading khi gọi API
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateFilter(),
                  SizedBox(height: 20),
                  _buildStatCard(
                      "📊 Tổng Doanh Thu", "$_totalRevenue VNĐ", Colors.green),
                  SizedBox(height: 10),
                  _buildStatCard("🎂 Số Bánh Đã Bán", "$_totalCakesSold cái",
                      Colors.orange),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchRevenueData, // Cập nhật dữ liệu
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    ),
                    child: Text("🔄 Lọc Dữ Liệu",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }

  /// 📌 **Bộ lọc ngày**
  Widget _buildDateFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateButton(
            "📅 Từ ngày", _startDate, () => _selectDate(context, true)),
        _buildDateButton(
            "📅 Đến ngày", _endDate, () => _selectDate(context, false)),
      ],
    );
  }

  /// 📌 **Nút chọn ngày**
  Widget _buildDateButton(String title, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : title),
              Icon(Icons.calendar_today, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 📌 **Widget hiển thị số liệu**
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.pie_chart, color: color, size: 30),
        title: Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}

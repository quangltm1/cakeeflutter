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
  List<dynamic> _filteredBills = []; // ✅ Danh sách bill đã lọc

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
    if (!mounted) return;

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
        List<dynamic> filteredBills = [];

        for (var bill in bills) {
          DateTime billDate = DateTime.parse(bill["deliveryDate"]);

          if (bill["status"] == 0) {
            if (_startDate != null && _endDate != null) {
              DateTime adjustedEndDate = _endDate!.add(Duration(days: 1)); // ✅ Cộng thêm 1 ngày

              if (billDate.isBefore(_startDate!) || billDate.isAtSameMomentAs(adjustedEndDate)) {
                continue;
              }
            }

            revenue += (bill["total"] as num).toDouble();
            cakesSold += (bill["quantity"] as num).toDouble();
            filteredBills.add(bill); // ✅ Thêm bill vào danh sách lọc
          }
        }

        if (mounted) {
          setState(() {
            _totalRevenue = revenue.toInt();
            _totalCakesSold = cakesSold.toInt();
            _filteredBills = filteredBills; // ✅ Lưu danh sách bill sau khi lọc
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Doanh Thu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFFFD900),
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // ✅ Hiển thị loading khi gọi API
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateFilter(),
                _buildRevenueSummary(),
                SizedBox(height: 10),
                _filteredBills.isEmpty
                    ? Expanded(child: Center(child: Text("Không có đơn hàng nào trong khoảng thời gian này!")))
                    : Expanded(child: _buildBillList()), // ✅ Hiển thị danh sách bill
              ],
            ),
    );
  }

  /// 📌 **Bộ lọc ngày + Nút Lọc**
  Widget _buildDateFilter() {
    return Container(
      color: Colors.grey[100],
      foregroundDecoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildDateButton("📅 Từ ngày", _startDate, () => _selectDate(context, true)),
            SizedBox(width: 10),
            _buildDateButton("📅 Đến ngày", _endDate, () => _selectDate(context, false)),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _fetchRevenueData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text("Lọc", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 **Nút chọn ngày**
  Widget _buildDateButton(String title, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : title),
              Icon(Icons.calendar_today, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 📌 **Hiển thị tổng doanh thu & số lượng bánh đã bán**
  Widget _buildRevenueSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(child: _buildStatCard("📊 Doanh Thu", NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(_totalRevenue), Colors.green)),
          SizedBox(width: 10),
          Expanded(child: _buildStatCard("🎂 Đã Bán", "$_totalCakesSold cái", Colors.orange)),
        ],
      ),
    );
  }

  /// 📌 **Widget hiển thị số liệu**
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// 📌 **Danh sách đơn hàng đã lọc**
  Widget _buildBillList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredBills.length,
      itemBuilder: (context, index) {
        var bill = _filteredBills[index];
        return Card(
          margin: EdgeInsets.only(bottom: 10),
          elevation: 3,
          color: Colors.white,
          child: ListTile(
            title: Text("🎂 Bánh: ${bill["cakeName"]}"),
            subtitle: Text("📅 Ngày giao: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(bill["deliveryDate"]))}\n"
                "💰 Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(bill["total"])}\n"
                "📦 Số lượng: ${bill["quantity"]} cái"),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }
}

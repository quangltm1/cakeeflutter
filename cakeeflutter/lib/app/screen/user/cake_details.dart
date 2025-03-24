import 'package:cakeeflutter/app/model/cart_item.dart';
import 'package:cakeeflutter/app/providers/cart_provider.dart';
import 'package:cakeeflutter/app/screen/user/checkout_nologin_page.dart';
import 'package:cakeeflutter/app/screen/user/checkout_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CakeDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const CakeDetailPage({super.key, required this.product});

  @override
  CakeDetailPageState createState() => CakeDetailPageState();
}

class CakeDetailPageState extends State<CakeDetailPage> {
  int soldQuantity = 0; // 🔹 Lưu số lượng bánh đã bán

  @override
  void initState() {
    super.initState();
    _fetchCakeSold(); // Gọi API lấy số lượng bánh đã bán
  }

  /// 🛒 **Gọi API lấy số lượng bánh đã bán**
Future<void> _fetchCakeSold() async {
  try {
    final response = await Dio().get(
      "https://fitting-solely-fawn.ngrok-free.app/api/Bill/GetCakeSoldByCake/${widget.product['id']}"
    );

    if (response.statusCode == 200) {
      setState(() {
        soldQuantity = response.data['totalSold'] ?? 0;
      });
    }
  } catch (e) {
    print("❌ Lỗi lấy số lượng bánh đã bán: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(backgroundColor: Colors.grey[100],),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: widget.product['cakeImage'],
                    child: Image.network(
                      widget.product['cakeImage'] ?? 'https://via.placeholder.com/300',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product['cakeName'] ?? 'Không có tên',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        SizedBox(height: 5),
                        Text(
                          "${widget.product['cakePrice'] ?? '0'} VNĐ",
                          style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            Text(" ${widget.product['cakeRating'] ?? '0'}", style: TextStyle(fontSize: 16)),
                            Spacer(),
                            Text("Đã bán: $soldQuantity", style: TextStyle(fontSize: 16)), // ✅ Hiển thị số lượng đã bán
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Text(
                          widget.product['cakeDescription'] ?? 'Mô tả sản phẩm chưa có.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD900),
                  ),
                  onPressed: () => _addToCart(context),
                  child: Text("🛒 Thêm vào giỏ hàng"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD900),
                  ),
                    onPressed: () => _buyNow(context),
                    child: Text("⚡ Mua ngay"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🛒 **Thêm vào giỏ hàng**
  void _addToCart(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Bạn cần đăng nhập để thêm vào giỏ hàng!")),
      );
      return;
    }

    CartItem newItem = CartItem(
      cakeId: widget.product['id']?.toString() ?? "",
      cakeName: widget.product['cakeName'] ?? "Không có tên",
      accessoryId: "",
      accessoryName: "",
      quantityCake: 1,
      quantityAccessory: 0,
      total: (widget.product['total'] ?? widget.product['cakePrice'] ?? 0).toDouble(),
    );

    try {
      bool success = await cartProvider.addToCart(newItem);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Đã thêm vào giỏ hàng!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Không thể thêm vào giỏ hàng!")),
        );
      }
    } catch (e) {
      print("🔴 Lỗi khi thêm vào giỏ hàng: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi không xác định!")),
      );
    }
  }

  /// ⚡ **Mua ngay**
  void _buyNow(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    if (token == null) {
      _showGuestCheckoutDialog(context);
    } else {
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Không tìm thấy thông tin người dùng")),
        );
      } else {
        _redirectToCheckout(context, userId);
      }
    }
  }

  void _redirectToCheckout(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cakeId: widget.product['id'].toString(),
          userId: userId,
          cakeName: widget.product['cakeName'] ?? 'Không có tên',
        ),
      ),
    );
  }

  /// 🛒 **Xử lý Đặt hàng cho khách vãng lai**
void _showGuestCheckoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Bạn có muốn đăng nhập?"),
      content: Text("Bạn có thể đăng nhập để lưu đơn hàng hoặc tiếp tục mua hàng mà không cần đăng nhập."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (widget.product['id'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuestOrderPage(
                    cakeId: widget.product['id'].toString(),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ Không tìm thấy sản phẩm!")),
              );
            }
          },
          child: Text("Tiếp tục mua hàng"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/login');
          },
          child: Text("Đăng nhập"),
        ),
      ],
    ),
  );
}

}

import 'package:cakeeflutter/app/model/cart_item.dart';
import 'package:cakeeflutter/app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout_page.dart'; // Import CheckoutPage cho người dùng đã đăng nhập
import 'checkout_nologin_page.dart'; // Import GuestOrderPage cho khách vãng lai

class CakeDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  CakeDetailPage({required this.product});


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
    productId: product['id'].toString(),
    cakeId: product['id'].toString(),
    accessoryId: "",
    quantityCake: 1,
    quantityAccessory: 0,
    total: product['cakePrice'].toDouble(),
    name: product['cakeName'] ?? "Không có tên",
    price: product['cakePrice'].toDouble(),
    imageUrl: product['cakeImage'] ?? 'https://via.placeholder.com/300',
  );

  // ✅ Kiểm tra giá trị trả về từ `addToCart`
  bool success = await cartProvider.addToCart(newItem);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Đã thêm vào giỏ hàng!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Lỗi khi thêm vào giỏ hàng!")),
    );
  }
}




  /// ⚡ **Xử lý Mua ngay**
  void _buyNow(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    if (token == null) {
      _showGuestCheckoutDialog(context); // Hiện hộp thoại cho thanh toán khách
    } else {
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Không tìm thấy thông tin người dùng")),
        );
      } else {
        _redirectToCheckout(context, userId); // Chuyển hướng tới CheckoutPage nếu người dùng đã đăng nhập
      }
    }
  }

  /// 🛒 **Xử lý Đặt hàng cho khách**
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
              if (product['id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuestOrderPage(
                      cakeId: product['id'].toString(),
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

  /// ✅ **Chuyển tới trang Checkout nếu đã đăng nhập**
void _redirectToCheckout(BuildContext context, String userId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CheckoutPage(
        cakeId: product['id'].toString(),
        userId: userId, // Gửi userId tới trang CheckoutPage
        cakeName: product['cakeName'] ?? 'Không có tên', // Pass cakeName here
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['cakeName'] ?? 'Chi tiết sản phẩm')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: product['cakeImage'],
                    child: Image.network(
                      product['cakeImage'] ?? 'https://via.placeholder.com/300',
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
                          product['cakeName'] ?? 'Không có tên',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            Text(" ${product['cakeRating'] ?? '0'}", style: TextStyle(fontSize: 16)),
                            Spacer(),
                            Text("Đã bán: ${product['sold'] ?? 0}", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          "${product['cakePrice'] ?? '0'} VNĐ",
                          style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          product['cakeDescription'] ?? 'Mô tả sản phẩm chưa có.',
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
                    onPressed: () => _addToCart(context),
                    child: Text("🛒 Thêm vào giỏ hàng"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
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
}

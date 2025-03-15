import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout_nologin_page.dart'; // Import GuestOrderPage

class CakeDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  CakeDetailPage({required this.product});

  /// 🛒 **Thêm vào giỏ hàng**
  void _addToCart(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🛒 Đã thêm vào giỏ hàng!")),
    );
  }

  /// ⚡ **Xử lý Mua ngay**
  void _buyNow(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    _showGuestCheckoutDialog(context); // Hiện hộp thoại chọn phương thức mua hàng
  } else {
    _processOrder(context); // Xử lý mua ngay nếu đã đăng nhập
  }
}

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

            // 🛠 Kiểm tra xem `cakeId` có null không
            if (product['id'] != null) {
              print("✅ id: ${product['id']}"); // Debug
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuestOrderPage(
                    cakeId: product['id'].toString(), // ✅ Fix lỗi null
                    quantity: 1,
                  ),
                ),
              );
            } else {
              print("❌ Không tìm thấy id"); // Debug
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ Không tìm thấy sản phẩm!")),
              );
            }
          },
          child: Text("Tiếp tục"),
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


  /// ✅ **Xử lý đặt hàng khi đã đăng nhập**
  void _processOrder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Mua ngay thành công!")),
    );
    // TODO: Thêm logic đặt hàng tại đây
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

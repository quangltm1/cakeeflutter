import 'package:flutter/material.dart';

class CakeDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  CakeDetailPage({required this.product});

  void _addToCart(BuildContext context) {
    // TODO: Gọi API hoặc cập nhật giỏ hàng trong app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã thêm vào giỏ hàng!")),
    );
  }

  void _buyNow(BuildContext context) {
    // TODO: Chuyển sang trang đặt hàng
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Mua ngay thành công!")),
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
          // 🛒 Thanh chứa nút "Thêm vào giỏ hàng" & "Mua ngay"
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("🛒 Thêm vào giỏ hàng", style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _buyNow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("⚡ Mua ngay", style: TextStyle(fontSize: 16)),
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

import 'package:cakeeflutter/app/model/cart_item.dart';

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  double totalPrice; // 🔹 Bỏ `final` để có thể cập nhật

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}

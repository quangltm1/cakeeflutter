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

  /// ✅ `fromJson()` để parse dữ liệu từ API
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  /// ✅ `toJson()` để convert thành JSON khi cần
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }

  /// ✅ `copyWith()` để cập nhật giỏ hàng mà không cần tạo mới
  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalPrice,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  String toString() => toJson().toString();
}

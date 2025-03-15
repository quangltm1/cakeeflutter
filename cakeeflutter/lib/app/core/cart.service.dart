import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart_item.dart';

class CartService {
  final Dio _dio = Dio();
  final String baseUrl = "https://fitting-solely-fawn.ngrok-free.app/api/ShoppingCart";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// 🛒 **Lấy giỏ hàng**
  Future<List<CartItem>> getCart() async {
  try {
    String? token = await _getToken();
    if (token == null) throw Exception("Chưa đăng nhập");

    Response response = await _dio.get(
      "$baseUrl/GetCart",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    print("🔍 API response: ${response.data}"); // Debug API response

    if (response.data is Map<String, dynamic> && response.data.containsKey('items')) {
      return (response.data['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    } else {
      throw Exception("Dữ liệu giỏ hàng không hợp lệ!");
    }
  } catch (e) {
    print("❌ Lỗi lấy giỏ hàng: $e");
    return [];
  }
}




  /// ➕ **Thêm sản phẩm vào giỏ hàng**
  Future<void> addToCart(CartItem item) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      await _dio.post(
        "$baseUrl/AddToCart",
        data: item.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("❌ Lỗi thêm vào giỏ hàng: $e");
    }
  }

  /// ❌ **Xóa sản phẩm khỏi giỏ hàng**
  Future<void> removeFromCart(String productId) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      await _dio.delete(
        "$baseUrl/RemoveFromCart/$productId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("❌ Lỗi xóa sản phẩm khỏi giỏ hàng: $e");
    }
  }

  /// 🔄 **Cập nhật số lượng sản phẩm**
  Future<void> updateCartItem(CartItem item) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      await _dio.put(
        "$baseUrl/UpdateCartItem",
        data: item.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("❌ Lỗi cập nhật giỏ hàng: $e");
    }
  }

  /// 🗑 **Xóa toàn bộ giỏ hàng**
  Future<void> clearCart() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      await _dio.delete(
        "$baseUrl/ClearCart",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("❌ Lỗi xóa giỏ hàng: $e");
    }
  }

  /// ✅ **Thanh toán giỏ hàng**
  Future<void> checkout() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      await _dio.post(
        "$baseUrl/Checkout",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("❌ Lỗi thanh toán: $e");
    }
  }
}

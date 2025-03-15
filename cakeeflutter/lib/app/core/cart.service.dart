import 'package:dio/dio.dart';
import '../model/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  final Dio _dio = Dio();
  final String baseUrl = "https://fitting-solely-fawn.ngrok-free.app/api/ShoppingCart";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<CartItem>> getCart() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      Response response = await _dio.get(
        "$baseUrl/GetCart",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      List<CartItem> cart = (response.data as List)
          .map((item) => CartItem.fromJson(item))
          .toList();

      return cart;
    } catch (e) {
      print("Lỗi lấy giỏ hàng: $e");
      return [];
    }
  }

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
      print("Lỗi thêm giỏ hàng: $e");
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      await _dio.delete(
        "$baseUrl/RemoveFromCart/$productId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("Lỗi xóa sản phẩm khỏi giỏ hàng: $e");
    }
  }

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
      print("Lỗi cập nhật giỏ hàng: $e");
    }
  }

  Future<void> clearCart() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa đăng nhập");

      await _dio.delete(
        "$baseUrl/ClearCart",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("Lỗi xóa giỏ hàng: $e");
    }
  }
}

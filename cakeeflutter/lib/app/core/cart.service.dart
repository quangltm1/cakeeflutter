import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart.dart';
import '../model/cart_item.dart';

class CartService {
  final Dio _dio = Dio();
  final String baseUrl = "https://fitting-solely-fawn.ngrok-free.app/api/ShoppingCart"; // 🔹 Thay bằng API thực tế

  /// 🛠 **Lấy Token từ SharedPreferences**
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// 🛒 **Lấy giỏ hàng**
  Future<Cart?> getCart() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("❌ Chưa đăng nhập");

      Response response = await _dio.get(
        "$baseUrl/GetCart",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return Cart.fromJson(response.data);
      }
    } catch (e) {
      print("❌ Lỗi lấy giỏ hàng: $e");
    }
    return null;
  }

  /// ➕ **Thêm sản phẩm vào giỏ hàng**
  Future<bool> addToCart(CartItem item) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("❌ Chưa đăng nhập");

      Response response = await _dio.post(
        "$baseUrl/AddToCart",
        data: item.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi thêm vào giỏ hàng: $e");
      return false;
    }
  }

  /// ❌ **Xóa sản phẩm khỏi giỏ hàng**
  Future<bool> removeFromCart(String productId) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("❌ Chưa đăng nhập");

      Response response = await _dio.delete(
        "$baseUrl/RemoveFromCart/$productId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi xóa sản phẩm khỏi giỏ hàng: $e");
      return false;
    }
  }

  /// 🔄 **Cập nhật số lượng sản phẩm**
  Future<bool> updateCartItem(CartItem item) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("❌ Chưa đăng nhập");

      Response response = await _dio.put(
        "$baseUrl/UpdateCartItem",
        data: item.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi cập nhật giỏ hàng: $e");
      return false;
    }
  }

  /// 🗑 **Xóa toàn bộ giỏ hàng**
  Future<bool> clearCart() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("❌ Chưa đăng nhập");

      Response response = await _dio.delete(
        "$baseUrl/ClearCart",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi xóa giỏ hàng: $e");
      return false;
    }
  }

  /// ✅ **Thanh toán giỏ hàng**
  Future<bool> checkout() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception("❌ Chưa đăng nhập");

      Response response = await _dio.post(
        "$baseUrl/Checkout",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi thanh toán: $e");
      return false;
    }
  }
}

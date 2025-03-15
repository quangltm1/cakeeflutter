import 'package:cakeeflutter/app/core/cart.service.dart';
import 'package:flutter/material.dart';
import '../model/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  Map<String, bool> _isUpdating = {}; // Trạng thái cập nhật từng sản phẩm

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  Map<String, bool> get isUpdating => _isUpdating;
  int get totalItems => _cartItems.length;
  double get totalPrice => _cartItems.fold(
      0,
      (sum, item) =>
          sum +
          (item.price * item.quantityCake +
              item.price * item.quantityAccessory));

  /// 🛒 **Lấy giỏ hàng**
  Future<void> fetchCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      _cartItems = await _cartService.getCart();

      print("✅ Giỏ hàng đã tải: $_cartItems");
    } catch (e) {
      print("❌ Lỗi lấy giỏ hàng: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ **Thêm sản phẩm vào giỏ hàng**
  Future<void> addToCart(CartItem item) async {
    _isProcessing = true;
    notifyListeners();
    await _cartService.addToCart(item);
    await fetchCart();
    _isProcessing = false;
    notifyListeners();
  }

  /// 🔄 **Cập nhật số lượng**
  Future<void> updateQuantity(String productId, int quantity) async {
    _isUpdating[productId] = true;
    notifyListeners();
    await _cartService.updateCartItem(CartItem(
      productId: productId,
      cakeId: "",
      accessoryId: "",
      quantityCake: quantity,
      quantityAccessory: 0,
      total: 0,
      name: "",
      price: 0,
      imageUrl: "",
    ));
    await fetchCart();
    _isUpdating[productId] = false;
    notifyListeners();
  }

  /// ❌ **Xóa sản phẩm khỏi giỏ hàng**
  Future<void> removeFromCart(String productId) async {
    _isProcessing = true;
    notifyListeners();
    await _cartService.removeFromCart(productId);
    await fetchCart();
    _isProcessing = false;
    notifyListeners();
  }

  /// 🗑 **Xóa toàn bộ giỏ hàng**
  Future<void> clearCart() async {
    _isProcessing = true;
    notifyListeners();
    await _cartService.clearCart();
    _cartItems.clear();
    _isProcessing = false;
    notifyListeners();
  }

  /// ✅ **Thanh toán giỏ hàng**
  Future<void> checkout() async {
    _isProcessing = true;
    notifyListeners();
    await _cartService.checkout();
    await fetchCart();
    _isProcessing = false;
    notifyListeners();
  }
}

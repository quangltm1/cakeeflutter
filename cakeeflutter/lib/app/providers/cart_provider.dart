import 'package:cakeeflutter/app/core/cart.service.dart';
import 'package:flutter/material.dart';
import '../model/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  final CartService _cartService = CartService();

  List<CartItem> get cartItems => _items;
  bool get isLoading => _isLoading;

  /// **Tính tổng số lượng sản phẩm trong giỏ hàng**
  int get totalItems {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  /// **Tính tổng giá trị giỏ hàng**
  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.price * item.quantity);
  }

  /// **Lấy giỏ hàng từ API**
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    _items = await _cartService.getCart();

    _isLoading = false;
    notifyListeners();
  }

  /// **Thêm sản phẩm vào giỏ hàng**
  Future<void> addToCart(CartItem item) async {
    await _cartService.addToCart(item);
    await fetchCart();
  }

  /// **Xóa sản phẩm khỏi giỏ hàng**
  Future<void> removeFromCart(String productId) async {
    await _cartService.removeFromCart(productId);
    await fetchCart();
  }

  /// **Cập nhật số lượng sản phẩm**
  Future<void> updateQuantity(String productId, int newQuantity) async {
  if (newQuantity < 1) return;
  
  _isLoading = true;
  notifyListeners();

  int index = _items.indexWhere((item) => item.productId == productId);
  if (index != -1) {
    _items[index] = CartItem(
      productId: _items[index].productId,
      name: _items[index].name,
      price: _items[index].price,
      quantity: newQuantity, // ✅ Cập nhật số lượng đúng cách
      imageUrl: _items[index].imageUrl,
    );
  }

  await _cartService.updateCartItem(_items[index]);

  _isLoading = false;
  await fetchCart();
}


  /// **Xóa toàn bộ giỏ hàng**
  Future<void> clearCart() async {
    await _cartService.clearCart();
    _items = [];
    notifyListeners();
  }
}

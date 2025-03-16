import 'package:cakeeflutter/app/core/cart.service.dart';
import 'package:flutter/material.dart';
import '../model/cart.dart';
import '../model/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  Cart? _cart;
  bool _isLoading = false;
  bool _isProcessing = false;
  Map<String, bool> _isUpdating = {}; // Trạng thái cập nhật từng sản phẩm
  String? _errorMessage;

  /// ✅ Getter để truy xuất trạng thái
  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  Map<String, bool> get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  
  /// ✅ Kiểm tra giỏ hàng trống
  bool get isCartEmpty => _cart == null || _cart!.items.isEmpty;
  
  /// ✅ Lấy tổng tiền từ API, không tự tính
  double get totalPrice => _cart?.totalPrice ?? 0;

  /// 🛒 **Lấy giỏ hàng từ API**
  Future<void> fetchCart() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _cart = await _cartService.getCart(); // Lấy giỏ hàng từ API
      print("✅ Giỏ hàng đã tải: $_cart");
    } catch (e) {
      _errorMessage = "Lỗi tải giỏ hàng!";
      print("❌ Lỗi lấy giỏ hàng: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ **Thêm sản phẩm vào giỏ hàng**
  Future<bool> addToCart(CartItem item) async {
    _isProcessing = true;
    notifyListeners();

    bool success = await _cartService.addToCart(item);
    if (success) {
      await fetchCart(); // Cập nhật lại giỏ hàng sau khi thêm
    }

    _isProcessing = false;
    notifyListeners();
    return success;
  }

  /// 🔄 **Cập nhật số lượng sản phẩm**
  Future<void> updateQuantity(String productId, int newQuantity) async {
  _isUpdating[productId] = true;
  notifyListeners();

  if (_cart != null) {
    List<CartItem> updatedItems = _cart!.items.map((item) {
      if (item.cakeId == productId) {
        return item.copyWith(quantityCake: newQuantity); // ✅ Cập nhật số lượng
      }
      return item;
    }).toList();

    _cart = _cart!.copyWith(items: updatedItems);
    notifyListeners();
  }

  bool success = await _cartService.updateCartItem(
    _cart!.items.firstWhere((item) => item.cakeId == productId),
  );

  if (success) {
    await fetchCart();
  }

  _isUpdating[productId] = false;
  notifyListeners();
}



  /// ❌ **Xóa sản phẩm khỏi giỏ hàng**
  Future<void> removeFromCart(String productId) async {
    _isProcessing = true;
    notifyListeners();

    bool success = await _cartService.removeFromCart(productId);
    if (success) {
      await fetchCart();
    }

    _isProcessing = false;
    notifyListeners();
  }

  /// 🗑 **Xóa toàn bộ giỏ hàng**
  Future<void> clearCart() async {
    _isProcessing = true;
    notifyListeners();

    bool success = await _cartService.clearCart();
    if (success) {
      _cart = null;
    }

    _isProcessing = false;
    notifyListeners();
  }

  /// ✅ **Thanh toán giỏ hàng**
  Future<void> checkout() async {
    _isProcessing = true;
    notifyListeners();

    bool success = await _cartService.checkout();
    if (success) {
      await fetchCart(); // Làm mới giỏ hàng sau khi thanh toán
    }

    _isProcessing = false;
    notifyListeners();
  }
}

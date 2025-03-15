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

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  Map<String, bool> get isUpdating => _isUpdating;
  int get totalItems => _cart?.items.length ?? 0;
  double get totalPrice {
  if (_cart == null || _cart!.items.isEmpty) return 0; // ✅ Kiểm tra null trước khi tính tổng
  return _cart!.items.fold(0, (sum, item) => sum + (item.total ?? 0));
}
 // ✅ Cập nhật tổng tiền giỏ hàng

  /// 🛒 **Lấy giỏ hàng từ API**
  Future<void> fetchCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      _cart = await _cartService.getCart();
      if (_cart != null) {
        _cart!.totalPrice = _cart!.items.fold(0, (sum, item) => sum + item.total); // ✅ Cập nhật tổng tiền khi tải giỏ hàng
      }

      print("✅ Giỏ hàng đã tải: $_cart");
    } catch (e) {
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

  bool success = await _cartService.addToCart(item); // Gọi API
  if (success) {
    await fetchCart(); // Làm mới giỏ hàng
  }

  _isProcessing = false;
  notifyListeners();
  return success; // ✅ Trả về bool để kiểm tra
}


  /// 🔄 **Cập nhật số lượng sản phẩm**
  Future<void> updateQuantity(String productId, int newQuantity) async {
    _isUpdating[productId] = true;
    notifyListeners();

    CartItem? item = _cart?.items.firstWhere(
      (i) => i.productId == productId,
      orElse: () => CartItem(
        productId: productId,
        cakeId: null,
        accessoryId: null,
        quantityCake: 0,
        quantityAccessory: 0,
        total: 0,
        name: '',
        price: 0,
        imageUrl: '',
      ),
    );

    if (item != null) {
      // ✅ Cập nhật số lượng và tính lại total cho sản phẩm
      item = CartItem(
        productId: item.productId,
        cakeId: item.cakeId,
        accessoryId: item.accessoryId,
        quantityCake: newQuantity,
        quantityAccessory: item.quantityAccessory,
        total: item.price * newQuantity + item.price * item.quantityAccessory, // ✅ Tính lại total chính xác
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
      );

      bool success = await _cartService.updateCartItem(item);
      if (success) {
        await fetchCart();
      }
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
      await fetchCart(); // ✅ Làm mới giỏ hàng sau khi thanh toán
    }

    _isProcessing = false;
    notifyListeners();
  }
}

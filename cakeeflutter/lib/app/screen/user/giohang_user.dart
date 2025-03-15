import 'package:cakeeflutter/app/model/cart_item.dart';
import 'package:cakeeflutter/app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text("Giỏ hàng (${cartProvider.totalItems})")),
      body: cartProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : cartProvider.cartItems.isEmpty
              ? Center(child: Text("Giỏ hàng trống"))
              : ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return _buildCartItem(cartProvider, item);
                  },
                ),
      bottomNavigationBar: cartProvider.cartItems.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: cartProvider.isProcessing
                    ? null
                    : () {
                        Navigator.pushNamed(context, "/checkout");
                      },
                child: cartProvider.isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Thanh toán (${cartProvider.totalPrice} VNĐ)"),
              ),
            ),
    );
  }

  Widget _buildCartItem(CartProvider cartProvider, CartItem item) {
    return ListTile(
      leading: Image.network(
        item.imageUrl,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image, size: 50),
      ),
      title: Text(item.name),
      subtitle: Text(
          "${item.price} VNĐ x ${item.quantityCake + item.quantityAccessory}"), // ✅ Sửa lỗi hiển thị tổng số lượng
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: item.quantityCake > 1
                ? () => cartProvider.updateQuantity(item.productId, item.quantityCake - 1)
                : null,
          ),
          Text("${item.quantityCake}"), // ✅ Hiển thị số lượng bánh đúng
          IconButton(
            icon: cartProvider.isUpdating[item.productId] == true
                ? CircularProgressIndicator(strokeWidth: 2)
                : Icon(Icons.add),
            onPressed: cartProvider.isUpdating[item.productId] == true
                ? null
                : () => cartProvider.updateQuantity(item.productId, item.quantityCake + 1),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              bool? confirmDelete = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Xóa sản phẩm"),
                  content: Text("Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Hủy"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Xóa"),
                    ),
                  ],
                ),
              );
              if (confirmDelete == true) {
                cartProvider.removeFromCart(item.productId);
              }
            },
          ),
        ],
      ),
    );
  }
}

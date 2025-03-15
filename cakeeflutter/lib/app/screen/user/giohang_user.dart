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
    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Giỏ hàng (${cartProvider.totalItems})")),
      body: cartProvider.cartItems.isEmpty
          ? Center(child: Text("Giỏ hàng trống"))
          : ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                return ListTile(
                  leading: Image.network(
                    item.imageUrl ?? '',
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 50),
                  ),
                  title: Text(item.name),
                  subtitle: Text("${item.price} VNĐ x ${item.quantity}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: item.quantity > 1
                            ? () => cartProvider.updateQuantity(item.productId, item.quantity - 1)
                            : null,
                      ),
                      Text("${item.quantity}"),
                      IconButton(
                        icon: cartProvider.isLoading
                            ? CircularProgressIndicator()
                            : Icon(Icons.add),
                        onPressed: cartProvider.isLoading
                            ? null
                            : () => cartProvider.updateQuantity(item.productId, item.quantity + 1),
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
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Hủy")),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Xóa")),
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
              },
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: cartProvider.cartItems.isEmpty
              ? null
              : () {
                  Navigator.pushNamed(context, "/checkout");
                },
          child: Text("Thanh toán (${cartProvider.totalPrice} VNĐ)"),
        ),
      ),
    );
  }
}

import 'package:cakeeflutter/app/model/cart_item.dart';
import 'package:cakeeflutter/app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(
        title: Text("Giỏ hàng (${cartProvider.cart?.items.length ?? 0})"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: cartProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : cartProvider.cart == null || cartProvider.cart!.items.isEmpty
              ? Center(child: Text("🛒 Giỏ hàng trống"))
              : ListView.builder(
                  itemCount: cartProvider.cart!.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cart!.items[index];
                    return _buildCartItem(cartProvider, item);
                  },
                ),
      bottomNavigationBar: cartProvider.cart == null || cartProvider.cart!.items.isEmpty
          ? null
          : _buildBottomBar(cartProvider),
    );
  }

  /// 📌 **Hiển thị từng sản phẩm trong giỏ hàng**
  Widget _buildCartItem(CartProvider cartProvider, CartItem item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(item.cakeName),
        subtitle: Text("${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(item.total)} x ${item.quantityCake}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: item.quantityCake > 1
                  ? () async {
                      await cartProvider.updateQuantity(item.cakeId, item.quantityCake - 1);
                      setState(() {});
                    }
                  : null,
            ),
            Text("${item.quantityCake}"),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await cartProvider.updateQuantity(item.cakeId, item.quantityCake + 1);
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await cartProvider.removeFromCart(item.cakeId);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 **Thanh toán & Tổng tiền**
  Widget _buildBottomBar(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(cartProvider.totalPrice)}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: cartProvider.isProcessing ? null : () => cartProvider.checkout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              minimumSize: Size(double.infinity, 50),
            ),
            child: cartProvider.isProcessing
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Thanh toán"),
          ),
        ],
      ),
    );
  }
}

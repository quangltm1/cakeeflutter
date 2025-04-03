import 'package:cakeeflutter/app/model/cart_item.dart';
import 'package:cakeeflutter/app/providers/cart_provider.dart';
import 'package:cakeeflutter/app/screen/user/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<CartProvider>(context, listen: false).fetchCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Giỏ hàng (${cartProvider.cart?.items.length ?? 0})"),
        centerTitle: true,
        backgroundColor: Color(0xFFFFD900),
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/cakeDetails', arguments: item.cakeId);
      },
      child: Card(
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
          onPressed: cartProvider.isProcessing
              ? null
              : () async {
                  // Lấy danh sách ID và tên bánh trong giỏ hàng
                  final cakeIds = cartProvider.cart?.items.map((item) => item.cakeId).toList() ?? [];
                  final cakeNames = cartProvider.cart?.items.map((item) => item.cakeName).toList() ?? [];

                  // Kiểm tra nếu giỏ hàng trống
                  if (cakeIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Giỏ hàng của bạn đang trống!")),
                    );
                    return;
                  }

                  // Kiểm tra nếu người dùng chưa đăng nhập
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('userId');
                  if (userId == null || userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Bạn cần đăng nhập để thanh toán!")),
                    );
                    return;
                  }

                  // Điều hướng tới CheckoutPage với dữ liệu bánh và người dùng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(
                        cakeId: cakeIds.join(", "),
                        cakeName: cakeNames.join(", "),
                        userId: userId,
                      ),
                    ),
                  );
                },
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

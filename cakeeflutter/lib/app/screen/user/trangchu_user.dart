import 'package:cakeeflutter/app/core/cake_service.dart';
import 'package:cakeeflutter/app/providers/cart_provider.dart';
import 'package:cakeeflutter/app/screen/user/cake_details.dart';
import 'package:cakeeflutter/app/screen/user/search_page.dart';
import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/core/category_service.dart';
import 'dart:developer';

import 'package:provider/provider.dart'; // Import for the log method

class TrangChuUserPage extends StatefulWidget {
  const TrangChuUserPage({super.key});

  @override
  TrangChuUserPageState createState() => TrangChuUserPageState();
}

class TrangChuUserPageState extends State<TrangChuUserPage> {
  final CakeService _cakeService = CakeService();
  final CategoryService _categoryService = CategoryService();

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId; // Nếu null, hiển thị tất cả bánh
  Future<List<Map<String, dynamic>>>? _cakesFuture;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAllCakes(); // 🔥 Lấy toàn bộ bánh khi vào trang
  }

  void _fetchCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      log("Error loading categories: $e", name: 'TrangChuUserPage');
    }
  }

  Future<void> _fetchAllCakes() async {
    // 🔥 Thêm Future<void>
    setState(() {
      _selectedCategoryId = null;
      _cakesFuture = _cakeService.getAllCakes();
    });
    await _cakesFuture; // ✅ Chờ dữ liệu
  }

  Future<void> _fetchCakesByCategory(String categoryId) async {
    // 🔥 Thêm Future<void>
    if (categoryId.isEmpty) return;

    setState(() {
      _selectedCategoryId = categoryId;
      _cakesFuture = _cakeService.getCakesByCategory(categoryId);
    });
    await _cakesFuture; // ✅ Chờ dữ liệu
  }

  Future<void> _handleRefresh() async {
    try {
      List<Map<String, dynamic>> newData;
      if (_selectedCategoryId == null) {
        newData = await _cakeService.getAllCakes();
      } else {
        newData = await _cakeService.getCakesByCategory(_selectedCategoryId!);
      }

      if (mounted) {
        setState(() {
          _cakesFuture = Future.value(newData);
        });
      }
    } catch (e) {
      log("❌ Error refreshing: $e", name: 'TrangChuUserPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: Color(0xFFFFD900),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/gio-hang');
                },
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cartProvider.cart?.items.length ?? 0}', // Replace '3' with the actual cart item count
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: _buildCategoryList(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _cakesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_shopping_cart,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "Không có bánh nào trong danh mục này!",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  var cakes = snapshot.data!;
                  return GridView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: cakes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return _buildProductItem(cakes[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: Text("Tìm kiếm bánh...",
                  style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
  return Container(
    height: 60,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),  // Thêm physics để cuộn mượt hơn
      padding: EdgeInsets.symmetric(horizontal: 8),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];

        if (!category.containsKey('categoryId') && !category.containsKey('id')) {
          return SizedBox(); 
        }

        final categoryId = category.containsKey('categoryId')
            ? category['categoryId'].toString()
            : category['id'].toString();

        final isSelected = _selectedCategoryId == categoryId;

        return GestureDetector(
          onTap: () {
            _fetchCakesByCategory(categoryId);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFFFD900) : Colors.white,
              border: Border.all(color: Colors.grey[200] ?? Colors.grey),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(0xFFFFD900).withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                category['categoryName'] ?? "Không có tên",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}




  Widget _buildProductItem(Map<String, dynamic> cake) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CakeDetailPage(product: cake),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
              blurRadius: 4,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  cake['cakeImage'] ?? "https://via.placeholder.com/150",
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cake['cakeName'] ?? 'Không có tên',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4), // Khoảng cách giữa tên và giá
                  Text(
                    "${(cake['cakePrice'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} VNĐ", // Hiển thị giá sản phẩm với định dạng 50.000 VNĐ
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

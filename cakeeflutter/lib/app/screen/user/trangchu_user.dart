import 'package:cakeeflutter/app/core/cake_service.dart';
import 'package:cakeeflutter/app/screen/user/cake_details.dart';
import 'package:cakeeflutter/app/screen/user/search_page.dart';
import 'package:flutter/material.dart';
import 'package:cakeeflutter/app/core/category_service.dart';

class TrangChuUserPage extends StatefulWidget {
  @override
  _TrangChuUserPageState createState() => _TrangChuUserPageState();
}

class _TrangChuUserPageState extends State<TrangChuUserPage> {
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
      print("Error loading categories: $e");
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
      print("❌ Error refreshing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(), // 🔥 Đặt thanh tìm kiếm vào AppBar
        backgroundColor: Color(0xFFFFD900),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryList(), // ✅ Danh mục
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh, // 🔥 Gọi hàm làm mới khi vuốt xuống
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
                      childAspectRatio: 0.75,
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
          MaterialPageRoute(
              builder: (context) =>
                  SearchPage()), // 🔥 Chuyển đến trang tìm kiếm
        );
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white, // 🔥 Đặt màu nền trắng
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(width: 10),
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Text("Tìm kiếm bánh...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];

          if (!category.containsKey('categoryId') &&
              !category.containsKey('id')) {
            return SizedBox(); // Bỏ qua danh mục lỗi
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 5)
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  category['categoryName'] ?? "Không có tên",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
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
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(0, 3),
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
                    "${cake['cakePrice'] ?? 0} VNĐ", // Hiển thị giá sản phẩm
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

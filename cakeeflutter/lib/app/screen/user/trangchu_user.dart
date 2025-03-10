import 'package:cakeeflutter/app/core/cake_service.dart';
import 'package:cakeeflutter/app/widgets/category_chip.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TrangChuUserPage extends StatefulWidget {
  @override
  _TrangChuUserPageState createState() => _TrangChuUserPageState();
}

class _TrangChuUserPageState extends State<TrangChuUserPage> {
  final CakeService _cakeService = CakeService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _searchCakes(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _cakeService.searchCakes(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print("Search error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trang chủ")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Bạn tìm bánh gì?',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _searchCakes, // Gọi API khi nhập text
            ),
            SizedBox(height: 20),
            Text('Danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                CategoryChip(label: "Lễ cưới", icon: Icons.favorite),
                SizedBox(width: 10),
                CategoryChip(label: "Sinh nhật", icon: Icons.cake),
              ],
            ),
            SizedBox(height: 20),
            Text("Kết quả tìm kiếm:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(child: Text("Không tìm thấy kết quả"))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final cake = _searchResults[index];
                            return ListTile(
                              leading: Image.network(
                            _getValidImageUrl(cake['cakeImage']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                              title: Text(cake['cakeName'] ?? 'No Name'),
                              subtitle: Text(cake['cakeDescription'] ?? 'No Description'),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
  String _getValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return "https://via.placeholder.com/150";
    }
    Uri? uri = Uri.tryParse(imageUrl);
    return (uri != null && (uri.scheme == "http" || uri.scheme == "https"))
        ? imageUrl
        : "https://via.placeholder.com/150";
  }
}

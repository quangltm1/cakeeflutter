import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  final Dio _dio = Dio();
  final String baseUrl = "https://fitting-solely-fawn.ngrok-free.app/api/Category"; // ✅ Thêm baseUrl

  Future<List<Map<String, dynamic>>> getCategories() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Response response = await _dio.get(
      '$baseUrl/Get All Category',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );


    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    }
  } catch (e) {
    print("❌ Error fetching categories: $e");
  }
  return [];
}


  Future<Map<String, dynamic>?> getCategoryById(String id) async {
    try {
      final response = await _dio.get(
        '$baseUrl/Get Category By Id', // ✅ Thêm baseUrl
        queryParameters: {'id': id},
        options: await _getAuthHeader(),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print("Error fetching category: $e");
    }
    return null;
  }

  Future<String?> getCategoryNameById(String id) async {
    try {
      final response = await _dio.get(
        '$baseUrl/Get Category Name By Id', // ✅ Thêm baseUrl
        queryParameters: {'id': id},
        options: await _getAuthHeader(),
      );
      if (response.statusCode == 200) {
        return response.data['CategoryName'];
      }
    } catch (e) {
      print("Error fetching category name: $e");
    }
    return null;
  }

  Future<bool> createCategory(String categoryName) async {
    try {
      final response = await _dio.post(
        '$baseUrl/Create Category', // ✅ Thêm baseUrl
        data: {'CategoryName': categoryName},
        options: await _getAuthHeader(),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error creating category: $e");
    }
    return false;
  }

  Future<bool> updateCategory(String id, String newName) async {
    try {
      final response = await _dio.patch(
        '$baseUrl/Update Category', // ✅ Thêm baseUrl
        queryParameters: {'id': id},
        data: {'CategoryName': newName},
        options: await _getAuthHeader(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating category: $e");
    }
    return false;
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/Delete Category', // ✅ Thêm baseUrl
        queryParameters: {'id': id},
        options: await _getAuthHeader(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting category: $e");
    }
    return false;
  }

  Future<Options> _getAuthHeader() async {
    String? token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<String?> _getToken() async { // ✅ Thêm hàm này để lấy token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

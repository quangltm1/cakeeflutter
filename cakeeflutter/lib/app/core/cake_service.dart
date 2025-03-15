// import 'package:dio/dio.dart';

// import 'base_service.dart';

// class CakeService extends BaseService {
//   Future<Response?> getCakesByUserId(String userId) => sendRequest("GET", "Cake/GetByUserId?id=$userId");

//   Future<Response?> createCake(Map<String, dynamic> cakeData) => sendRequest("POST", "Cake/Create Cake", data: cakeData);

//   Future<Response?> updateCake(String cakeId, Map<String, dynamic> updateData) => sendRequest("PATCH", "Cake/$cakeId", data: updateData);

//   Future<Response?> deleteCake(String cakeId) => sendRequest("DELETE", "Cake/Delete Cake?id=$cakeId");
// }
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CakeService {
  final Dio _dio = Dio();
  final String baseUrl =
      "https://fitting-solely-fawn.ngrok-free.app/api/Cake"; // Thay URL API của bạn

//search cake
  Future<List<Map<String, dynamic>>> searchCakes(String query) async {
    try {
      final response = await _dio.get("$baseUrl/text-search", queryParameters: {
        "query": query,
      });

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception("Failed to load cakes");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getCakesByCategory(
      String categoryId) async {
    if (categoryId.isEmpty) {
      return [];
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      Response response = await _dio.get(
        '$baseUrl/GetCakesByCategory',
        queryParameters: {'categoryId': categoryId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );


      if (response.statusCode == 200) {
        List<Map<String, dynamic>> cakes =
            List<Map<String, dynamic>>.from(response.data);
        return cakes;
      } else if (response.statusCode == 404) {
        return []; // ✅ Trả về danh sách rỗng thay vì throw lỗi
      } else {
        throw Exception('Failed to load cakes');
      }
    } catch (e) {
      return []; // ✅ Nếu lỗi, cũng trả về danh sách rỗng để tránh crash app
    }
  }

  Future<List<Map<String, dynamic>>> getAllCakes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      Response response = await _dio.get(
        '$baseUrl/Get_All_Cake', // 🔥 API lấy tất cả bánh
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load cakes');
      }
    } catch (e) {
      throw Exception('Error fetching cakes: $e');
    }
  }
}

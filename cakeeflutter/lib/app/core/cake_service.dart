// import 'package:dio/dio.dart';

// import 'base_service.dart';

// class CakeService extends BaseService {
//   Future<Response?> getCakesByUserId(String userId) => sendRequest("GET", "Cake/GetByUserId?id=$userId");

//   Future<Response?> createCake(Map<String, dynamic> cakeData) => sendRequest("POST", "Cake/Create Cake", data: cakeData);

//   Future<Response?> updateCake(String cakeId, Map<String, dynamic> updateData) => sendRequest("PATCH", "Cake/$cakeId", data: updateData);

//   Future<Response?> deleteCake(String cakeId) => sendRequest("DELETE", "Cake/Delete Cake?id=$cakeId");
// }
import 'package:dio/dio.dart';

class CakeService {
  final Dio _dio = Dio();
  final String baseUrl = "https://fitting-solely-fawn.ngrok-free.app/api/Cake"; // Thay URL API của bạn

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
}
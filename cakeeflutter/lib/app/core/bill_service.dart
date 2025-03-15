import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bill.dart'; // Import model Bill

class BillService {
  final Dio _dio = Dio();
  final String baseUrl = "https://fitting-solely-fawn.ngrok-free.app/api/Bill";

  // Get Bill of custom
  Future<List<Bill>> getBillOfCustom(String customerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("🚨 Token không tồn tại. Hãy đăng nhập lại!");
      }

      final response = await _dio.get(
        "$baseUrl/GetBillByCustomId",
        queryParameters: {"id": customerId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );


      if (response.statusCode == 200) {
        if (response.data == null || response.data.isEmpty) {
          return []; // Trả về danh sách rỗng nếu API trả về null
        }

        List<dynamic> data = response.data;
        return data
            .map((e) => Bill.fromJson(e ?? {}))
            .toList(); // Thêm `{}` để tránh lỗi `null`
      } else {
        throw Exception("🚨 API trả về lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("🔴 Lỗi khi gọi API: $e");
      throw Exception("Error: $e");
    }
  }
}

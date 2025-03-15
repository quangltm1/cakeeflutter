import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bill.dart'; // Import model Bill

class BillService {
  static Dio _dio = Dio();
  static String baseUrl = "https://fitting-solely-fawn.ngrok-free.app/api/Bill";

  /// 🔹 **Lấy danh sách hóa đơn của khách hàng đã đăng nhập**
  Future<List<Bill>> getBillOfCustom(String customerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("🚨 Token không tồn tại. Hãy đăng nhập lại!");
      }

      final response = await _dio.get(
  "$baseUrl/GetBillByCustomId/$customerId",  // Đưa customerId vào URL
  options: Options(headers: {"Authorization": "Bearer $token"}),
);


      if (response.statusCode == 200) {
        if (response.data == null || response.data.isEmpty) {
          return []; // Trả về danh sách rỗng nếu API trả về null
        }

        List<dynamic> data = response.data;
        return data.map((e) => Bill.fromJson(e ?? {})).toList(); // Chuyển đổi dữ liệu sang `Bill`
      } else {
        throw Exception("🚨 API trả về lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("🔴 Lỗi khi gọi API: $e");
      throw Exception("Error: $e");
    }
  }

  /// 🔹 **Tạo hóa đơn cho khách đã đăng nhập**
  static Future<bool> createBill(Map<String, dynamic> billData) async {
    try {
      Response response = await _dio.post(
        "$baseUrl/CreateBill",
        data: billData,
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi tạo đơn hàng: $e");
      return false;
    }
  }

  /// 🔹 **Đặt hàng cho khách vãng lai (không cần đăng nhập)**
  Future<bool> placeOrderForGuest({
    required String name,
    required String phone,
    required String address,
    required String cakeId,
    required int quantity,
  }) async {
    final url = "$baseUrl/CreateBillForGuest";

    final data = {
      "BillDeliveryCustomName": name, // ✅ Tên khách vãng lai
      "BillDeliveryPhone": phone,
      "BillDeliveryAddress": address,
      "BillCakeId": cakeId,
      "BillCakeQuantity": quantity,
      "BillStatus": 1, // 🚀 Mặc định trạng thái "Pending"
    };

    try {
      final response = await _dio.post(url, data: data);

      if (response.statusCode == 200) {
        print("✅ Đặt hàng thành công: ${response.data}");
        return true;
      } else {
        print("❌ API trả về lỗi: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi đặt hàng: $e");
      return false;
    }
  }
}

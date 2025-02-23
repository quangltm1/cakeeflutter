import 'package:cakeeflutter/app/model/register.dart';
import 'package:cakeeflutter/app/model/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  final Dio _dio = Dio();
  String baseUrl = "https://fitting-solely-fawn.ngrok-free.app";

  API() {
    _dio.options.baseUrl = "$baseUrl/api";
  }

  Dio get sendRequest => _dio;
}

class APIRepository {
  API api = API();

  Map<String, dynamic> header(String token) {
    return {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer $token'
    };
  }

  Future<String> register(Signup user, bool isSeller) async {
  try {
    String endpoint = isSeller ? '/User/Create Admin' : '/User/Create User';

    Response res = await api.sendRequest.post(
      endpoint,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      }),
      data: user.toJson(),
    );

    print("Response Data: ${res.data} | Status: ${res.statusCode}"); // Debug

    if (res.statusCode == 200 || res.statusCode == 201) { // Chấp nhận cả 201 Created
      return "ok";
    } else {
      return "Đăng ký thất bại: ${res.data['Message'] ?? 'Lỗi không xác định'}";
    }
  } catch (ex) {
    return "Lỗi đăng ký: ${ex.toString()}";
  }
}




  Future<String?> login(String accountID, String password) async {
  try {
    final body = {
      "userName": accountID,
      "passWord": password
    };

    Response res = await api.sendRequest.post(
      '/User/login',
      options: Options(headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      }),
      data: body,
    );

    print("🔹 Response từ API: ${res.data}"); // Debug response

    if (res.statusCode == 200 && res.data != null) {
      String? tokenData = res.data['token'];
      int? role = res.data['role']; // Lấy role chính xác

      if (tokenData != null && role != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', tokenData);
        prefs.setInt('role', role);

        print("✅ Token: $tokenData | Role: $role");
        return tokenData;
      } else {
        print("❌ Lỗi: Không tìm thấy token hoặc role trong response");
        return null;
      }
    } else {
      print("❌ Lỗi: Status Code ${res.statusCode}");
      return null;
    }
  } catch (ex) {
    print("❌ Exception khi login(): $ex");
    return null;
  }
}


  Future<User?> current(String token) async {
  try {
    String bearerToken = "Bearer $token"; // Thêm "Bearer "

    print("🔄 Gửi request lấy user với token: $bearerToken"); // Debug token

    Response res = await api.sendRequest.get(
      '/User/current',
      options: Options(
        headers: {
          "Authorization": bearerToken,  // Gửi "Bearer {token}"
          "Content-Type": "application/json",
        },
      ),
    );

    print("✅ Dữ liệu user trả về: ${res.data}"); // Debug response

    if (res.statusCode == 200 && res.data != null) {
      return User.fromJson(res.data);
    } else {
      print("❌ Lỗi: Không lấy được thông tin user");
      return null;
    }
  } catch (ex) {
    print("❌ Lỗi API current(): $ex");
    return null;
  }
}







}

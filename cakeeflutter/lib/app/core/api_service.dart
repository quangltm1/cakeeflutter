import 'package:cakeeflutter/app/model/cake.dart';
import 'package:cakeeflutter/app/model/category.dart';
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

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Chấp nhận cả 201 Created
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
      final body = {"userName": accountID, "passWord": password};

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
        int? role = res.data['role'];

        if (tokenData != null && role != null) {
          var user =
              await APIRepository().current(tokenData); // Lấy user từ API
          if (user != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', tokenData);
            await prefs.setInt('role', role);
            await prefs.setString('userId',
                user.id.toString()); // ⚡ Sửa lỗi: Lưu userId dưới dạng String

            print(
                "✅ Đăng nhập thành công! Token: $tokenData | Role: $role | UserID: ${user.id}");
            return tokenData;
          } else {
            print("❌ Lỗi: Không thể lấy thông tin user sau khi đăng nhập.");
            return null;
          }
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

      Response res = await api.sendRequest.get(
        '/User/current',
        options: Options(
          headers: {
            "Authorization": bearerToken, // Gửi "Bearer {token}"
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

  Future<List<Cake>> fetchCakesByUserId(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('❌ Token không tồn tại. Vui lòng đăng nhập lại.');
      }

      String bearerToken = "Bearer $token";
      Response res = await api.sendRequest.get(
        '/Cake/GetByUserId?userId=$userId',
        options: Options(
          headers: {
            "Authorization": bearerToken,
            "Content-Type": "application/json",
          },
        ),
      );

      if (res.statusCode == 200 && res.data != null) {
        List<dynamic> jsonResponse = res.data;

        return jsonResponse.map((cake) => Cake.fromJson(cake)).toList();
      } else {
        throw Exception('⚠️ Không thể lấy danh sách bánh.');
      }
    } catch (e) {
      throw Exception('❌ Lỗi fetchCakesByUserId(): $e');
    }
  }

  Future<List<Category>> getCategoryByUserID(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      Response res = await api.sendRequest.get(
        '/Category/GetCategoryByUserId?userId=$userId', // <-- Đúng route

        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (res.statusCode == 200 && res.data != null) {
        List<dynamic> jsonResponse = res.data;
        return jsonResponse.map((data) => Category.fromJson(data)).toList();
      } else {
        throw Exception('⚠️ Không thể lấy danh mục bánh.');
      }
    } catch (e) {
      throw Exception('❌ Lỗi getCategoryByUserID(): $e');
    }
  }

  Future<bool> deleteCake(String cakeId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      Response res = await api.sendRequest.delete(
        '/Cake/Delete Cake?id=$cakeId',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (res.statusCode == 200) {
        return true; // ✅ Xóa thành công
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCake(
      String cakeId, Map<String, dynamic> updateData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      Response res = await api.sendRequest.patch(
        '/Cake/$cakeId',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: updateData,
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCategoryName(String cakeId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      Response res = await api.sendRequest.get(
        '/Cake/Get Category Of Cake?cakeId=$cakeId',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (res.statusCode == 200 && res.data != null) {
        return res.data["CategoryName"]; // Trả về tên danh mục
      } else {
        return "Không xác định";
      }
    } catch (e) {
      return "Lỗi danh mục";
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      Response res = await api.sendRequest.get('/Cake/GetAllCategories');

      if (res.statusCode == 200 && res.data != null) {
        return res.data
            .map<Category>((json) => Category.fromJson(json))
            .toList();
      } else {
        throw Exception("Lỗi API: ${res.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        return false;
      }

      Response res = await api.sendRequest.delete(
        '/Cake/Delete Category?categoryId=$categoryId',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> createCake(Map<String, dynamic> cakeData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        return false;
      }

      // Xóa `id` trước khi gửi request để tránh lỗi
      cakeData.remove("id");


      Response res = await api.sendRequest.post(
        '/Cake/Create Cake',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: cakeData,
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

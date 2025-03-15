import 'package:cakeeflutter/app/model/acessory.dart';
import 'package:cakeeflutter/app/model/cake.dart';
import 'package:cakeeflutter/app/model/cakesize.dart';
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

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Lấy userId đã lưu khi đăng nhập
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

            return tokenData;
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (ex) {
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

      if (res.statusCode == 200 && res.data != null) {
        return User.fromJson(res.data);
      } else {
        return null;
      }
    } catch (ex) {
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
        '/Category/Delete Category?id=$categoryId',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );


      return res.statusCode == 200;
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

  Future<Category?> getCategoryById(String categoryId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      String url = '/Category/Get Category By Id?id=$categoryId';

      Response res = await api.sendRequest.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );


      if (res.statusCode == 200 && res.data != null) {
        Category category = Category.fromJson(res.data);
        return category;
      } else {
        throw Exception('⚠️ Không thể lấy danh mục.');
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> addCategory(String categoryName) async {
    try {
      String? token = await _getToken();
      String? userId = await _getUserId(); // Lấy userId từ SharedPreferences

      if (userId == null) {
        return false;
      }

      Response res = await api.sendRequest.post(
        '/Category/Create Category',
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
        data: {
          "categoryName": categoryName,
          "userId": userId,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 📌 Cập nhật danh mục
  Future<bool> updateCategory(String categoryId, String newCategoryName) async {
    try {
      String? token = await _getToken();
      Response res = await api.sendRequest.patch(
        '/Category/Update Category?id=$categoryId',
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
        data: {"categoryName": newCategoryName},
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //Acessory
  Future<List<Acessory>> fetchAcessoriesByUserId(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('❌ Token không tồn tại. Vui lòng đăng nhập lại.');
      }

      String bearerToken = "Bearer $token";
      Response res = await api.sendRequest.get(
        '/Acessory/GetAcessoryByUserId?userId=$userId',
        options: Options(
          headers: {
            "Authorization": bearerToken,
            "Content-Type": "application/json",
          },
        ),
      );

      if (res.statusCode == 200 && res.data != null) {
        List<dynamic> jsonResponse = res.data;

        return jsonResponse
            .map((acessory) => Acessory.fromJson(acessory))
            .toList();
      } else {
        throw Exception('⚠️ Không thể lấy danh sách phụ kiện.');
      }
    } catch (e) {
      throw Exception('❌ Lỗi fetchAcessoriesByUserId(): $e');
    }
  }

  //Create Acessory
  Future<bool> createAcessory(String name, double price, String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      Response res = await APIRepository().api.sendRequest.post(
        '/Acessory/Create Acessory',
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
        data: {
          "acessoryName": name,
          "acessoryPrice": price,
          "userId": userId,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //Delete Acessory
  Future<bool> deleteAcessory(String acessoryId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      Response res = await api.sendRequest.delete(
        '/Acessory/Delete Acessory?id=$acessoryId',
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

  //Update Acessory
  Future<bool> updateAcessory(
      String acessoryId, String name, double price) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      // Tạo URL với query parameters
      String url =
          '/Acessory/UpdateAccessory?id=$acessoryId&name=$name&price=$price';

      Response res = await api.sendRequest.patch(
        url,
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

  //get acessory by id
  Future<Acessory?> getAcessoryById(String acessoryId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }

      String url = '/Acessory/Get Acessory By Id?id=$acessoryId';

      Response res = await api.sendRequest.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );


      if (res.statusCode == 200 && res.data != null) {
        Acessory acessory = Acessory.fromJson(res.data);
        return acessory;
      } else {
        throw Exception('⚠️ Không thể lấy phụ kiện.');
      }
    } catch (e) {
      return null;
    }
  }

  /// ✅ **Thêm mới Cake Size**
  Future<bool> createCakeSize(String sizeName, String userId) async {
  try {
    String? token = await _getToken();
    if (token == null) throw Exception("❌ Token không tồn tại.");


    Response res = await api.sendRequest.post(
      '/CakeSize/Create Cake Size',
      options: Options(headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      }),
      data: {
        "sizeName": sizeName,
        "userId": userId,
      },
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


  /// ✅ **Cập nhật Cake Size**
  Future<bool> updateCakeSize(String cakeSizeId, String newSizeName) async {
    try {
      String? token = await _getToken();
      if (token == null) {
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");
      }


      Response res = await api.sendRequest.patch(
        '/CakeSize/Update Cake Size?id=$cakeSizeId', // Đúng endpoint
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
        data: {
          "sizeName": newSizeName, // 🔥 Chỉ truyền đúng name
        },
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

  /// ✅ **Xóa Cake Size**
  Future<bool> deleteCakeSize(String cakeSizeId) async {
    try {
      String? token = await _getToken();
      if (token == null)
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");


      Response res = await api.sendRequest.delete(
        '/CakeSize/Delete Cake Size?id=$cakeSizeId',
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
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

  Future<CakeSize?> getCakeSizeById(String cakeSizeId) async {
    try {
      String? token = await _getToken();
      if (token == null) {
        return null;
      }

      String url =
          '/CakeSize/Get Cake Size By Id?id=$cakeSizeId'; // 🔥 Đổi thành đường dẫn đúng

      Response res = await api.sendRequest.get(
        url,
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );


      if (res.statusCode == 200 && res.data != null) {
        return CakeSize.fromJson(res.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<CakeSize>> fetchCakeSizesByUserId(String userId) async {
    try {
      String? token = await _getToken();
      if (token == null)
        throw Exception("❌ Token không tồn tại. Vui lòng đăng nhập lại.");

      Response res = await api.sendRequest.get(
        '/CakeSize/GetByUserId?id=$userId',
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );


      if (res.statusCode == 200 && res.data != null) {
        List<dynamic> jsonResponse = res.data;
        List<CakeSize> sizes =
            jsonResponse.map((data) => CakeSize.fromJson(data)).toList();


        return sizes;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

}

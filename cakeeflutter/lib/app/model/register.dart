class Signup {
  String userName;
  String password;
  String confirmPassword;
  String fullName;
  String phoneNumber;

  Signup({
    required this.userName,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
    required this.phoneNumber,
  });

  // Chuyển đối tượng thành JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "password": password,
      "confirmPassword": confirmPassword,
      "fullName": fullName,
      "phone": phoneNumber,
    };
  }
}

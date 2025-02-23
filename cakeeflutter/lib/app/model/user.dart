class User {
  final String id;
  final String userName;
  final String fullName;
  final String phoneNumber;
  final int role;

  User({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['Id'] ?? '', // Kiểm tra API trả về key nào
      userName: json['UserName'] ?? '',
      fullName: json['FullName'] ?? '',
      phoneNumber: json['Phone'] ?? '',
      role: int.tryParse(json['Role'].toString()) ?? 0,
    );
  }
}

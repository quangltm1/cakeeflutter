class User {
  final String id;
  final String userName;
  final String fullName;
  final String phone;
  final int role; // Đảm bảo kiểu dữ liệu là int

  User({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      fullName: json['fullName'],
      phone: json['phone'],
      role: json['role'] is int ? json['role'] : int.tryParse(json['role'].toString()) ?? 0, // Chuyển role về int
    );
  }
}

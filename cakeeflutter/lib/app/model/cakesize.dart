class CakeSize {
  final String id;
  final String sizeName;
  final String userId;

  CakeSize({required this.id, required this.sizeName, required this.userId});

  factory CakeSize.fromJson(Map<String, dynamic> json) {
    print("📌 Chuyển đổi JSON thành CakeSize: $json");

    return CakeSize(
      id: json['id'] ?? '',
      sizeName: json['cakeSizeName']?.toString() ?? '', // Chuyển thành string
      userId: json['userId'] ?? '',
    );
  }
}

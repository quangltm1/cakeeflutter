class Category {
  final String id;
  final String categoryName;
  final String userId;

  Category(
      {required this.id, required this.categoryName, required this.userId});

  factory Category.fromJson(Map<String, dynamic> json) {
  print("📌 Parsing JSON: $json"); // Debug dữ liệu đầu vào

  return Category(
    id: json['id'] ?? '',
    categoryName: json['categoryName'] ?? 'Unknown', // Đã cập nhật thành 'name'
    userId: json['userId'] ?? '',
  );
}

}

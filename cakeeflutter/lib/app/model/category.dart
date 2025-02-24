class Category {
  final String id;
  final String categoryName;
  final String userId;

  Category({required this.id, required this.categoryName, required this.userId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'], 
      categoryName: json['name'] ?? 'Unknown',
      userId: json['userId'] ?? '',
    );
  }
}

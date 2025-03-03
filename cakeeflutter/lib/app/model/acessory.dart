class Acessory {
  final String id;
  final String acessoryName;
  final double acessoryPrice; // Sửa Float thành double
  final String acessoryShopId;

  Acessory({
    required this.id,
    required this.acessoryName,
    required this.acessoryPrice,
    required this.acessoryShopId,
  });

  factory Acessory.fromJson(Map<String, dynamic> json) {
    return Acessory(
      id: json['id'] ?? '',
      acessoryName: json['acessoryName'].toString(), // Chuyển đổi từ int -> String
      acessoryPrice: (json['acessoryPrice'] ?? 0).toDouble(), // Chuyển từ int sang double
      acessoryShopId: json['acessoryShopId'] ?? '',
    );
  }
}

class Cake {
  final String id;
  final String cakeName;
  final int cakeSize;
  final String cakeDescription;
  final double cakePrice;
  final String cakeImage;
  final double cakeRating;
  final int cakeStock;
  final String cakeCategoryId;
  final String userId;

  Cake({
    required this.id,
    required this.cakeName,
    required this.cakeSize,
    required this.cakeDescription,
    required this.cakePrice,
    required this.cakeImage,
    required this.cakeRating,
    required this.cakeStock,
    required this.cakeCategoryId,
    required this.userId,
  });

  factory Cake.fromJson(Map<String, dynamic> json) {
    return Cake(
      id: json['id'].toString(),
      cakeName: json['cakeName'] ?? "Không có tên",
      cakeSize: int.tryParse(json['cakeSize'].toString()) ?? 0,
      cakeDescription: json['cakeDescription'] ?? "Không có mô tả",
      cakePrice: double.tryParse(json['cakePrice'].toString()) ?? 0,
      cakeImage: json['cakeImage'] ?? "",
      cakeRating: double.tryParse(json['cakeRating'].toString()) ?? 0,
      cakeStock: int.tryParse(json['cakeQuantity'].toString()) ?? 0,
      cakeCategoryId: json['cakeCategoryId'].toString(),
      userId: json['userId'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cakeName": cakeName,
      "cakeSize": cakeSize,
      "cakeDescription": cakeDescription,
      "cakePrice": cakePrice,
      "cakeImage": cakeImage,
      "cakeCategoryId": {"_id": cakeCategoryId}, // ObjectId trong MongoDB
      "cakeRating": cakeRating,
      "cakeQuantity": cakeStock,
      "userId": {"_id": userId}, // ObjectId trong MongoDB
    };
  }
}

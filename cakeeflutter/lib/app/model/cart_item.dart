class CartItem {
  final String productId;
  final String cakeId;
  final String accessoryId;
  final int quantityCake;
  final int quantityAccessory;
  final double total;
  final String imageUrl;
  final String name;
  final double price;

  CartItem({
    required this.productId,
    required this.cakeId,
    required this.accessoryId,
    required this.quantityCake,
    required this.quantityAccessory,
    required this.total,
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  // ✅ Parse JSON từ API
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['cakeId'] ?? json['accessoryId'] ?? '',
      cakeId: json['cakeId'] ?? '',
      accessoryId: json['accessoryId'] ?? '',
      quantityCake: json['quantityCake'] ?? 0,
      quantityAccessory: json['quantityAccessory'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      name: json['name'] ?? 'Sản phẩm không có tên',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  // ✅ Convert sang JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'cakeId': cakeId,
      'accessoryId': accessoryId,
      'quantityCake': quantityCake,
      'quantityAccessory': quantityAccessory,
      'total': total,
    };
  }
}

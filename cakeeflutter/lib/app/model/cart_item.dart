class CartItem {
  final String productId;
  final String? cakeId;
  final String? accessoryId;
  final int quantityCake;
  final int quantityAccessory;
  final double total;
  final String name;
  final double price;
  final String imageUrl;

  CartItem({
    required this.productId,
    this.cakeId,
    this.accessoryId,
    required this.quantityCake,
    required this.quantityAccessory,
    required this.total,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['cakeId']?.toString() ?? json['accessoryId']?.toString() ?? '',
      cakeId: json['cakeId']?.toString(),
      accessoryId: json['accessoryId']?.toString(),
      quantityCake: json['quantityCake'] ?? 0,
      quantityAccessory: json['quantityAccessory'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
      name: json['name'] ?? 'Không có tên',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }

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

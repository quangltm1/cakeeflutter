class CartItem {
  final String cakeId;
  final String cakeName;
  final String? accessoryId;
  final String accessoryName;
  final int quantityCake;
  final int quantityAccessory;
  final double total;

  CartItem({
    required this.cakeId,
    required this.cakeName,
    this.accessoryId,
    required this.accessoryName,
    required this.quantityCake,
    required this.quantityAccessory,
    required this.total,
  });

  /// ✅ Hàm `copyWith()` để cập nhật sản phẩm mà không tạo mới hoàn toàn
  CartItem copyWith({
    String? cakeId,
    String? cakeName,
    String? accessoryId,
    String? accessoryName,
    int? quantityCake,
    int? quantityAccessory,
    double? total,
  }) {
    return CartItem(
      cakeId: cakeId ?? this.cakeId,
      cakeName: cakeName ?? this.cakeName,
      accessoryId: accessoryId ?? this.accessoryId,
      accessoryName: accessoryName ?? this.accessoryName,
      quantityCake: quantityCake ?? this.quantityCake,
      quantityAccessory: quantityAccessory ?? this.quantityAccessory,
      total: total ?? this.total,
    );
  }

  /// ✅ `fromJson()` để parse dữ liệu từ API
  factory CartItem.fromJson(Map<String, dynamic> json) {
  return CartItem(
    cakeId: json['cakeId'].toString(),
    cakeName: json['cakeName'] ?? 'Không có tên',  // 🔹 Fix: Lấy đúng `cakeName`
    accessoryId: json['accessoryId']?.toString() ?? '', // 🔹 Fix lỗi chính tả
    accessoryName: json['accessoryName'] ?? 'Không có tên',
    quantityCake: json['quantityCake'] ?? 0,
    quantityAccessory: json['quantityAccessory'] ?? 0,
    total: (json['total'] ?? 0).toDouble(),
  );
}



  /// ✅ `toJson()` để convert thành JSON khi cần
  Map<String, dynamic> toJson() {
    return {
      'cakeId': cakeId,
      'cakeName': cakeName,
      'accessoryId': accessoryId,
      'accessoryName': accessoryName,
      'quantityCake': quantityCake,
      'quantityAccessory': quantityAccessory,
      'total': total,
    };
  }

  @override
  String toString() => toJson().toString();
}

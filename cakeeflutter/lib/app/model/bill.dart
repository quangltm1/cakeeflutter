class Bill {
  String id;
  String customName;
  String address;
  String phone;
  String deliveryDate;
  int deposit;
  String note;
  String receiveDate;
  int status;
  int total;
  String cakeContent;
  String cakeName;
  int cakeSize;
  String accessory;
  int quantity;

  Bill({
    required this.id,
    required this.customName,
    required this.address,
    required this.phone,
    required this.deliveryDate,
    required this.deposit,
    required this.note,
    required this.receiveDate,
    required this.status,
    required this.total,
    required this.cakeContent,
    required this.cakeName,
    required this.cakeSize,
    required this.accessory,
    required this.quantity,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] ?? "", // Tránh lỗi Null
      customName: json['customName'] ?? "Khách hàng", 
      address: json['address'] ?? "Chưa có địa chỉ",
      phone: json['phone'] ?? "Chưa có số điện thoại",
      deliveryDate: json['deliveryDate'] ?? "0000-00-00", 
      deposit: json['deposit'] ?? 0,
      note: json['note'] ?? "",
      receiveDate: json['receiveDate'] ?? "0000-00-00",
      status: json['status'] ?? 0,
      total: json['total'] ?? 0,
      cakeContent: json['cakeContent'] ?? "Không có nội dung",
      cakeName: json['cakeName'] ?? "Không có tên bánh",
      cakeSize: json['cakeSize'] ?? 0,
      accessory: json['accessory'] ?? "Không có phụ kiện",
      quantity: json['quantity'] ?? 1,
    );
  }
}

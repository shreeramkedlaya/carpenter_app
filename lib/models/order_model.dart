class Customer {
  int? customerId;
  String name;
  String contactNumber;
  String address;
  int orgId;
  String orgName;
  bool enabled;
  bool deleted;

  Customer({
    this.customerId,
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.orgId,
    this.orgName = 'Wood_Partner',
    this.enabled = true,
    this.deleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'name': name,
      'contactNumber': contactNumber,
      'address': address,
      'orgId': orgId,
      'orgName': orgName,
      'enabled': enabled ? 1 : 0,
      'deleted': deleted ? 1 : 0,
    };
  }
}

class Order {
  int? orderId;
  String customerName;
  String mobile;
  String place;
  int orgId;
  String orderStatus;
  double orderAmount;
  double advanceAmount;
  double dueAmount;
  DateTime orderDate;

  Order({
    this.orderId,
    required this.customerName,
    required this.mobile,
    required this.place,
    required this.orgId,
    this.orderStatus = 'in-progress',
    this.orderAmount = 0.0,
    this.advanceAmount = 0.0,
    this.dueAmount = 0.0,
    DateTime? orderDate, // Accepts DateTime
  }) : orderDate = orderDate ?? DateTime.now(); // Default if null

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'],
      customerName: map['customerName'],
      mobile: map['mobile'],
      place: map['place'],
      orgId: map['orgId'],
      orderStatus: map['orderStatus'],
      orderAmount: (map['orderAmount'] as num).toDouble(),
      advanceAmount: (map['advanceAmount'] as num).toDouble(),
      dueAmount: (map['dueAmount'] as num).toDouble(),
      orderDate: map['orderDate'] != null
          ? DateTime.parse(map['orderDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'mobile': mobile,
      'place': place,
      'orgId': orgId,
      'orderStatus': orderStatus,
      'orderAmount': orderAmount,
      'advanceAmount': advanceAmount,
      'dueAmount': dueAmount,
      'orderDate': orderDate.toIso8601String(), // Convert DateTime to String
    };
  }
}

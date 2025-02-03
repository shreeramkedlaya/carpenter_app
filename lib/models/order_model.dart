class Order {
  final String id;
  final String customerName;
  final String address;
  // order status
  final Map<String, String> statusDictionary = {
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'in_progress': 'In Progress',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
  };
  // due date
  final DateTime dueDate;
  // order status
  final String status;

  Order(
    this.dueDate, {
    required this.id,
    required this.customerName,
    required this.address,
    required this.status,
    required String name,
  });
}

class Status {
  final String text;
  final String value;

  const Status({required this.text, required this.value});
}

// list of statuses
final List<Status> statuses = const [
  Status(text: 'Pending', value: 'pending'),
  Status(text: 'Started', value: 'started'),
  Status(text: 'In Progress', value: 'in-progress'),
  Status(text: 'Confirmed', value: 'confirmed'),
  Status(text: 'Delivered', value: 'delivered'),
  Status(text: 'Cancelled', value: 'cancelled'),
];

class Item {
  final String id;
  final String name;
  int quantity;
  bool isChecked; // Track whether the checkbox is checked

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    this.isChecked = false,
  });
}
// sample items
  final List<Item> sampleItems = [
    Item(id: '1', name: 'Table', quantity: 0),
    Item(id: '2', name: 'Chair', quantity: 0),
    Item(id: '3', name: 'Cupboard', quantity: 0),
  ];
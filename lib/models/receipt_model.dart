// receipt_model.dart
class Receipt {
  final String id;
  final String userId;
  final String name;
  final String location;
  final List<Item> items;
  final double totalPrice;
  final String status;

  Receipt({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.items,
    required this.totalPrice,
    required this.status,
  });

  factory Receipt.fromMap(Map<String, dynamic> data, String documentId) {
    List<Item> itemsList = (data['items'] as List).map((item) => Item.fromMap(item)).toList();
    return Receipt(
      id: documentId,
      userId: data['userId'],
      name: data['name'],
      location: data['location'],
      items: itemsList,
      totalPrice: data['totalPrice'],
      status: data['status'],
    );
  }
}

class Item {
  final String name;
  final double price;
  final int quantity;

  Item({
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory Item.fromMap(Map<String, dynamic> data) {
    return Item(
      name: data['name'],
      price: data['price'],
      quantity: data['quantity'],
    );
  }
}

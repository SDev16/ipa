class CartItem {
  final String imageUrl;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Convert CartItem to a Map
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Create a CartItem from a Map
  static CartItem fromMap(Map<String, dynamic> map) {
    return CartItem(
      imageUrl: map['imageUrl'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}

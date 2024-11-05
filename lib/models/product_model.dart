class Product {
  final String name;
  final double price;
  final String imageUrl;

  Product({required this.name, required this.price, required this.imageUrl});
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

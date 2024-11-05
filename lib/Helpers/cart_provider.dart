import 'package:flutter/foundation.dart';
import 'package:faap/models/cart_model.dart' as cartmodel;

class Cart extends ChangeNotifier {
  final List<cartmodel.CartItem> _items = [];

  // Get the list of cart items
  List<cartmodel.CartItem> get items => _items;

  // Add an item to the cart
  void add(cartmodel.CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  // Remove an item from the cart
  void remove(cartmodel.CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  // Calculate total price of items in the cart
  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity; // Multiply price by quantity
    }
    return total;
  }
}

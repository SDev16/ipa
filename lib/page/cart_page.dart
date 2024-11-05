import 'package:cached_network_image/cached_network_image.dart';
import 'package:faap/models/const.dart';
import 'package:faap/page/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faap/Helpers/cart_provider.dart';
import 'package:faap/models/cart_model.dart' as cartmodel; // Assuming this has CartItem
import 'package:intl/intl.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the Cart provider
    final cart = Provider.of<Cart>(context);
    final List<cartmodel.CartItem> cartItems = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Cached Image
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Item details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat.currency(decimalDigits: 0,locale: 'fr_FR', symbol: 'frs ')
                                    .format(item.price),
                                style: const TextStyle(fontSize: 16, color: Colors.green),
                              ),
                              const SizedBox(height: 4),
                              Text('Quantity: ${item.quantity}'),
                            ],
                          ),
                        ),
                        // Remove Button
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            // Remove item from cart
                            cart.remove(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} removed from cart!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${NumberFormat.currency(decimalDigits: 0,locale: 'fr_FR', symbol: 'frs ').format(cart.totalPrice)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proceeding to checkout...'),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CheckoutPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white
                      ),
                      child: const Text('Checkout',),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

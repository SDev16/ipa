import 'package:faap/models/const.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faap/Helpers/cart_provider.dart';
import 'package:faap/models/cart_model.dart' as cartmodel;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createReceipt(BuildContext context, List<cartmodel.CartItem> cartItems) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    String receiptId = const Uuid().v4();

    final receiptData = {
      'id': receiptId,
      'userId': userId,
      'name': _nameController.text,
      'location': _locationController.text,
      'items': cartItems.map((item) => {
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      }).toList(),
      'totalPrice': cartItems.fold(0.0, (total, item) => total + (item.price * item.quantity)),
      'status': 'Pending',
    };

    await FirebaseFirestore.instance.collection('receipts').doc(receiptId).set(receiptData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt created successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final List<cartmodel.CartItem> cartItems = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: item.imageUrl,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.bold),
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
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Total: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'frs ', decimalDigits: 0).format(cart.totalPrice)}',

                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Checkout'),
                              content: const Text('Are you sure you want to complete the purchase?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await _createReceipt(context, cartItems);
                                    cart.clearCart();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Checkout Now'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

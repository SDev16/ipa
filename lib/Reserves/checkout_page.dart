// // ignore_for_file: invalid_use_of_visible_for_testing_member

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:faap/Helpers/cart_provider.dart';
// import 'package:faap/models/cart_model.dart' as cartmodel; // Adjust the import as necessary
// import 'package:intl/intl.dart';

// class CheckoutPage extends StatelessWidget {
//   const CheckoutPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Access the Cart provider
//     final cart = Provider.of<Cart>(context);
//     final List<cartmodel.CartItem> cartItems = cart.items;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Checkout'),
//         backgroundColor: Colors.teal,
//       ),
//       body: cartItems.isEmpty
// /          ? const Center(
//               child: Text(
//                 'Your cart is empty!',
//                 style: TextStyle(fontSize: 20, color: Colors.grey),
//               ),
//             )
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Item List
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: cartItems.length,
//                       itemBuilder: (context, index) {
//                         final item = cartItems[index];
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 10),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 70,
//                                   height: 70,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                     image: DecorationImage(
//                                       image: NetworkImage(item.imageUrl),
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(item.name,
//                                           style: const TextStyle(
//                                               fontSize: 18, fontWeight: FontWeight.bold)),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         NumberFormat.currency(locale: 'fr_FR', symbol: 'frs ')
//                                             .format(item.price),
//                                         style: const TextStyle(fontSize: 16, color: Colors.green),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text('Quantity: ${item.quantity}'),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   // Total Price
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     child: Text(
//                       'Total: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'frs ').format(cart.totalPrice)}',
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   // Checkout Button
//                   ElevatedButton(
//                     onPressed: () {
//                       // Proceed with the checkout logic (e.g., payment processing)
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Checkout complete!'),
//                           duration: Duration(seconds: 2),
//                         ),
//                       );
//                       // Clear the cart after checkout (optional)
//                       cart.items.clear();
//                       // ignore: invalid_use_of_protected_member
//                       cart.notifyListeners();
//                       // Navigate back or to a confirmation page
//                       Navigator.pop(context); // Go back to the previous page
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.teal,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text('Complete Purchase'),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

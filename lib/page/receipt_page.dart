import 'package:faap/models/receipt_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  late Future<List<Receipt>> _receiptsFuture;

  @override
  void initState() {
    super.initState();
    _receiptsFuture = _fetchReceipts();
  }

  Future<List<Receipt>> _fetchReceipts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return []; // Return an empty list if the user is not logged in
    }

    final snapshot = await FirebaseFirestore.instance.collection('receipts').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Receipt.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> _markAsReceived(String receiptId) async {
    await FirebaseFirestore.instance.collection('receipts').doc(receiptId).update({'status': 'Received'});
    setState(() {
      _receiptsFuture = _fetchReceipts(); // Refresh the receipt list
    });
  }

  Future<void> _showConfirmationDialog(String receiptId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Receipt'),
          content: const Text('Are you sure you have received your order?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without doing anything
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _markAsReceived(receiptId); // Mark as received
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Receipt>>(
        future: _receiptsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching receipts'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No receipts found.'));
          }

          final receipts = snapshot.data!;
          return ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Receipt ID: ${receipt.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Name: ${receipt.name}'),
                      Text('Location: ${receipt.location}'),
                      Text('Total Price: ${receipt.totalPrice.toStringAsFixed(0)}'),
                      Text('Status: ${receipt.status}'),
                      const SizedBox(height: 10),
                      const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...receipt.items.map((item) => Text('${item.name} - ${item.quantity} x ${item.price.toStringAsFixed(0)}')),
                      const SizedBox(height: 10),
                      if (receipt.status == 'In Progress')
                        ElevatedButton(
                          onPressed: () => _showConfirmationDialog(receipt.id),
                          child: const Text('Mark as Received'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

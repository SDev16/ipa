import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faap/models/receipt_model.dart'; // Ensure this matches your project structure

class ManageReceiptsPage extends StatefulWidget {
  const ManageReceiptsPage({super.key});

  @override
  _ManageReceiptsPageState createState() => _ManageReceiptsPageState();
}

class _ManageReceiptsPageState extends State<ManageReceiptsPage> {
  String _filterStatus = 'All';
  String _searchQuery = '';
  late Future<List<Receipt>> _receiptsFuture;

  @override
  void initState() {
    super.initState();
    _receiptsFuture = _fetchReceipts();
  }

  Future<List<Receipt>> _fetchReceipts() async {
    final snapshot = await FirebaseFirestore.instance.collection('receipts').get();
    return snapshot.docs.map((doc) => Receipt.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> _updateReceiptStatus(String receiptId, String newStatus) async {
    await FirebaseFirestore.instance.collection('receipts').doc(receiptId).update({'status': newStatus});
    setState(() {
      _receiptsFuture = _fetchReceipts(); // Refresh the list after updating
    });
  }

  Future<void> _deleteReceipt(String receiptId) async {
    await FirebaseFirestore.instance.collection('receipts').doc(receiptId).delete();
    setState(() {
      _receiptsFuture = _fetchReceipts(); // Refresh the list after deleting
    });
  }

  Future<void> _showDeleteConfirmationDialog(String receiptId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Receipt'),
          content: const Text('Are you sure you want to delete this receipt?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteReceipt(receiptId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  List<Receipt> _applyFilter(List<Receipt> receipts) {
    List<Receipt> filteredReceipts = receipts;

    // Apply status filter
    if (_filterStatus != 'All') {
      filteredReceipts = filteredReceipts.where((receipt) => receipt.status == _filterStatus).toList();
    }

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      filteredReceipts = filteredReceipts
          .where((receipt) => receipt.id.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filteredReceipts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Receipts'),
        backgroundColor: Colors.teal,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _filterStatus,
              items: <String>['All', 'Pending', 'In Progress', 'Completed', 'Cancelled', 'Received']
                  .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _filterStatus = newValue!;
                });
              },
              dropdownColor: Colors.teal,
              iconEnabledColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Receipt ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Receipt>>(
              future: _receiptsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching receipts'));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('No receipts found.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final receipts = _applyFilter(snapshot.data!);
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _receiptsFuture = _fetchReceipts();
                    });
                  },
                  child: ListView.builder(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Receipt ID: ${receipt.id.substring(0, 8)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmationDialog(receipt.id),
                                  ),
                                ],
                              ),
                              Text('User: ${receipt.name}'),
                              Text('Location: ${receipt.location}'),
                              Text('Total Price: ${receipt.totalPrice.toStringAsFixed(0)}'),
                              Text('Status: ${receipt.status}'),
                              const SizedBox(height: 10),
                              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...receipt.items.map((item) => Text('${item.name} - ${item.quantity} x ${item.price.toStringAsFixed(0)}')),
                              const SizedBox(height: 10),
                              DropdownButton<String>(
                                value: receipt.status,
                                items: <String>['Pending', 'In Progress', 'Completed', 'Cancelled', 'Received']
                                    .map((status) => DropdownMenuItem<String>(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                                onChanged: (newStatus) {
                                  _updateReceiptStatus(receipt.id, newStatus!);
                                },
                                underline: Container(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

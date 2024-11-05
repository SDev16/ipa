import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ManageItemsPage extends StatefulWidget {
  const ManageItemsPage({super.key});

  @override
  _ManageItemsPageState createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> {
  final CollectionReference itemsRef = FirebaseFirestore.instance.collection('items');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Items'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items found.'));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot item = snapshot.data!.docs[index];
              return ListTile(
                leading: Image.network(item['imageUrl'], height: 50, width: 50, fit: BoxFit.cover),
                title: Text(item['name']),
                subtitle: Text('Price: \$${item['price'].toString()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editItem(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(item),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to edit item
  Future<void> _editItem(DocumentSnapshot item) async {
    TextEditingController nameController = TextEditingController(text: item['name']);
    TextEditingController priceController = TextEditingController(text: item['price'].toString());
    TextEditingController descriptionController = TextEditingController(text: item['description']);
    double rating = item['rating'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Rating:'),
                  Slider(
                    value: rating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    onChanged: (newRating) {
                      setState(() {
                        rating = newRating;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await itemsRef.doc(item.id).update({
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0,
                'description': descriptionController.text,
                'rating': rating,
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Function to delete item
  Future<void> _deleteItem(DocumentSnapshot item) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete image from Firebase Storage
              String imageUrl = item['imageUrl'];
              await FirebaseStorage.instance.refFromURL(imageUrl).delete();

              // Delete item from Firestore
              await itemsRef.doc(item.id).delete();

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted successfully.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

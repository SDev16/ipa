import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ManageUploadsPage extends StatefulWidget {
  const ManageUploadsPage({super.key});

  @override
  _ManageUploadsPageState createState() => _ManageUploadsPageState();
}

class _ManageUploadsPageState extends State<ManageUploadsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  File? _newImageFile;

  // Fetch uploads from Firestore
  Stream<QuerySnapshot> _getUploadsStream() {
    return _firestore.collection('uploads').orderBy('timestamp', descending: true).snapshots();
  }

  // Update an existing item
  Future<void> _updateItem(String docId, Map<String, dynamic> updatedData) async {
    await _firestore.collection('uploads').doc(docId).update(updatedData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item updated successfully!')),
    );
  }

  // Pick a new image for updating an item
  Future<void> _pickNewImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  // Upload new image and get its URL
  Future<String> _uploadNewImage(String docId) async {
    final storageRef = FirebaseStorage.instance.ref().child('uploads/$docId.jpg');
    await storageRef.putFile(_newImageFile!);
    return await storageRef.getDownloadURL();
  }

  // Delete an item from Firestore and Firebase Storage
  Future<void> _deleteItem(String docId, String imageUrl) async {
    await _firestore.collection('uploads').doc(docId).delete();
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted successfully!')),
    );
  }

  // Show dialog for updating item information
  void _showUpdateDialog(String docId, Map<String, dynamic> currentData) {
    final TextEditingController nameController = TextEditingController(text: currentData['name']);
    final TextEditingController ratingController = TextEditingController(text: currentData['rating']);
    final TextEditingController descriptionController = TextEditingController(text: currentData['description']);
    final TextEditingController priceController = TextEditingController(text: currentData['price'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: ratingController, decoration: const InputDecoration(labelText: 'Rating')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickNewImage,
              child: const Text('Pick New Image (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final updatedData = {
                'name': nameController.text,
                'rating': ratingController.text,
                'description': descriptionController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
              };

              // If a new image was picked, upload it and update the imageUrl
              if (_newImageFile != null) {
                String newImageUrl = await _uploadNewImage(docId);
                updatedData['imageUrl'] = newImageUrl;
              }

              await _updateItem(docId, updatedData);

              // Clear the new image file after update
              setState(() {
                _newImageFile = null;
              });
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Uploads'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUploadsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No uploads found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                title: Text(data['name']),
                subtitle: Text('\$${data['price']} - Rating: ${data['rating']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showUpdateDialog(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Confirm delete action
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Item'),
                            content: const Text('Are you sure you want to delete this item?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          await _deleteItem(doc.id, data['imageUrl']);
                        }
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

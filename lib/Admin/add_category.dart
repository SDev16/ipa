import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  File? _iconFile;
  bool _isLoading = false;
  String? _deletingCategoryId;

  // Function to pick an icon
  Future<void> _pickIcon() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _iconFile = File(pickedFile.path);
      });
    }
  }

  // Function to upload category to Firebase
  Future<void> _uploadCategory() async {
    if (_nameController.text.isEmpty || _iconFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and select an icon.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child('icons/$fileName');
      await storageRef.putFile(_iconFile!);
      String downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('categories').add({
        'name': _nameController.text,
        'iconUrl': downloadUrl,
        'iconPath': storageRef.fullPath, // Save the icon path for deletion
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added successfully!')),
      );
      _nameController.clear();
      setState(() {
        _iconFile = null;
      });
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to delete a category from Firebase
  Future<void> _deleteCategory(String docId, String iconPath) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmDelete != true) return;

    setState(() {
      _deletingCategoryId = docId;
    });

    try {
      await FirebaseStorage.instance.ref(iconPath).delete();
      await FirebaseFirestore.instance.collection('categories').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category: $e')),
      );
    } finally {
      setState(() {
        _deletingCategoryId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickIcon,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: _iconFile != null
                      ? DecorationImage(image: FileImage(_iconFile!), fit: BoxFit.cover)
                      : null,
                ),
                child: _iconFile == null
                    ? const Center(child: Text('Pick Icon'))
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadCategory,
                    child: const Text('Add Category'),
                  ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No categories found.'));
                  }
                  final categories = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      bool isDeleting = _deletingCategoryId == category.id;
                      return ListTile(
                        leading: Image.network(
                          category['iconUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                        ),
                        title: Text(category['name']),
                        trailing: isDeleting
                            ? const CircularProgressIndicator()
                            : IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCategory(category.id, category['iconPath']),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

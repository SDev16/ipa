import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _rating = 0.0;
  double _price = 0.0;
  String _description = '';
  String? _selectedCategory;
  File? _image;
  bool _isLoading = false;

  List<DocumentSnapshot> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = snapshot.docs;
    });
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('item_images')
        .child('${DateTime.now()}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();

      try {
        final imageUrl = await _uploadImage(_image!);

        await FirebaseFirestore.instance.collection('items').add({
          'name': _name,
          'rating': _rating,
          'price': _price,
          'description': _description,
          'imageUrl': imageUrl,
          'categoryId': _selectedCategory,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _selectedCategory,
                        hint: const Text('Select Category'),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a category.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter a name.';
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Rating',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter a rating.';
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _rating = double.parse(value!);
                        },
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter a price.';
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _price = double.parse(value!);
                        },
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter a description.';
                          return null;
                        },
                        onSaved: (value) {
                          _description = value!;
                        },
                      ),
                      const SizedBox(height: 10),
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _image!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.grey,
                            ),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Select Image'),
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _submitForm,
                                child: const Text('Add Item'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  }

  Future<void> _uploadData() async {
    if (_imageFile == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image.')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String id = const Uuid().v4();
      String imageUrl = await _uploadImageToStorage(id);

      await FirebaseFirestore.instance.collection('uploads').doc(id).set({
        'name': _nameController.text,
        'imageUrl': imageUrl,
        'rating': _reviewController.text,
        'description': _descriptionController.text,
        'price': price,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload successful!')),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String> _uploadImageToStorage(String id) async {
    final storageRef = FirebaseStorage.instance.ref().child('uploads/$id.jpg');
    await storageRef.putFile(_imageFile!);
    return await storageRef.getDownloadURL();
  }

  void _clearForm() {
    setState(() {
      _imageFile = null;
      _nameController.clear();
      _reviewController.clear();
      _descriptionController.clear();
      _priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Trending'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.camera_alt),
                      )
                    : Image.file(_imageFile!, width: 100, height: 100, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reviewController,
                decoration: const InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a rating';
                  final rating = int.tryParse(value);
                  if (rating == null || rating < 1 || rating > 5) {
                    return 'Please enter a rating between 1 and 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a description';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  if (price == null || price < 0) return 'Please enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() == true) {
                          _uploadData();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

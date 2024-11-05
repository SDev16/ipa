import 'package:faap/Helpers/items_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchItemsAndUploads() async {
    try {
      // Fetch items from "items" collection
      final itemsSnapshot = await _firestore.collection('items').get();
      final items = itemsSnapshot.docs.map((doc) => doc.data()).toList();

      // Fetch uploads from "uploads" collection
      final uploadsSnapshot = await _firestore.collection('uploads').get();
      final uploads = uploadsSnapshot.docs.map((doc) => doc.data()).toList();

      // Combine both lists
      return [...items, ...uploads];
    } catch (e) {
      print('Error fetching data: $e');
      rethrow; // Propagate the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Page"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchItemsAndUploads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No items available"));
          }

          final items = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsPage(
                            imageUrl: item['imageUrl'] ?? '',
                            name: item['name'] ?? 'No Name',
                            review: item['rating'] != null ? item['rating'].toString() : 'No Review',
                            price: (item['price'] as num?)?.toDouble() ?? 0,
                            description: item['description'] ?? 'No Description',
                          ),
                        ),
                      );
                },
                child: ItemCard(
                  name: item['name'] ?? 'No Name',
                  imageUrl: item['imageUrl'] ?? '',
                  price: item['price'], // Pass price directly
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final dynamic price; // Changed to dynamic

  const ItemCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text("\$ ${price.toString()}", // Convert price to string
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

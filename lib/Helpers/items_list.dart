import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faap/Helpers/items_detail_page.dart';
import 'package:flutter/material.dart';

class ItemListPage extends StatelessWidget {
  final String categoryId;

  const ItemListPage({Key? key, required this.categoryId}) : super(key: key);

  Future<String> _getCategoryName() async {
    final categorySnapshot =
        await FirebaseFirestore.instance.collection('categories').doc(categoryId).get();
    return categorySnapshot['name'] ?? 'Unknown Category';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getCategoryName(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(snapshot.hasData ? snapshot.data! : 'Loading...'),
            centerTitle: true,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('categoryId', isEqualTo: categoryId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error fetching data.'),
                      ElevatedButton(
                        onPressed: () {
                          // Optionally, you can implement a retry logic here by refreshing the data
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No items found in this category.'));
              }

              final items = snapshot.data!.docs;

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    title: Text(item['name'] ?? 'No Name'),
                    subtitle: Text(
                      'Price: ${item['price'] != null ? (item['price'] as num).toStringAsFixed(0) : '0'}',

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.image_not_supported),
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
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

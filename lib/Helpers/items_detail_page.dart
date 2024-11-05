import 'package:cached_network_image/cached_network_image.dart';
import 'package:faap/Helpers/cart_provider.dart';
import 'package:faap/Helpers/favorite_provider.dart';
import 'package:faap/models/const.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:faap/models/cart_model.dart' as cartmodel;

class ItemDetailsPage extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String review;
  final double price;
  final String? description;

  const ItemDetailsPage({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.review,
    required this.price,
    required this.description,
  }) : super(key: key);

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  int quantity = 1; // Default quantity

  TextStyle getTextStyle(double fontSize, FontWeight fontWeight, Color color) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(widget.name);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Details'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              if (isFavorite) {
                favoritesProvider.removeFavorite(widget.name);
              } else {
                favoritesProvider.addFavorite(
                  cartmodel.CartItem(
                    imageUrl: widget.imageUrl,
                    name: widget.name,
                    price: widget.price,
                    quantity: quantity,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Section with CachedNetworkImage
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  // Name Section
                  Text(
                    widget.name,
                    style: getTextStyle(28, FontWeight.bold, Colors.green[700]!),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Price Section
                  Text(
                    NumberFormat.currency(decimalDigits: 0,locale: 'fr_FR', symbol: 'frs ')
                        .format(widget.price),
                    style: getTextStyle(20, FontWeight.w700, Colors.green[700]!),
                  ),
                  const SizedBox(height: 16),
                  // Review Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rating: ${widget.review}',
                      style: getTextStyle(18, FontWeight.w600, Colors.green[700]!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description Section
                  if (widget.description != null && widget.description!.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description:',
                        style: getTextStyle(18, FontWeight.w600, Colors.green[700]!),
                      ),
                    ),
                    Text(
                      widget.description!,
                      style: getTextStyle(16, FontWeight.normal, Colors.grey[800]!),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                  ),
                  Text(
                    '$quantity',
                    style: getTextStyle(24, FontWeight.bold, Colors.green[700]!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Add to Cart Button
              ElevatedButton.icon(
                onPressed: () {
                  cartmodel.CartItem newItem = cartmodel.CartItem(
                    imageUrl: widget.imageUrl,
                    name: widget.name,
                    price: widget.price,
                    quantity: quantity,
                  );
                  Provider.of<Cart>(context, listen: false).add(newItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.name} added to cart!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  'Add to Cart',
                  style: getTextStyle(18, FontWeight.w600, Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

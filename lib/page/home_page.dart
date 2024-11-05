import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faap/Admin/add_category.dart';
import 'package:faap/Admin/add_items.dart';
import 'package:faap/Admin/add_trending.dart';
import 'package:faap/Admin/manage_items.dart';
import 'package:faap/Admin/manage_receipts.dart';
import 'package:faap/Admin/manage_trends.dart';
import 'package:faap/Helpers/items_detail_page.dart';
import 'package:faap/Helpers/items_list.dart';
import 'package:faap/models/const.dart';
import 'package:faap/models/foodcategory.dart';
import 'package:faap/models/foodtrending.dart';
import 'package:faap/page/receipt_page.dart';
import 'package:faap/page/shop_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<FoodCategory> foodCategory = [];
  final searchController = TextEditingController();
String? selectedCategoryId; // Add this line at the class level


Future<void> _fetchReceiptCount() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid; // Get the current user's unique ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('receipts')
          .where('userId', isEqualTo: userId) // Query only current user's receipts
          .get();
      setState(() {
        receiptCount = querySnapshot.docs.length;
      });
    } else {
      print('No user is currently signed in.');
    }
  } catch (e) {
    print('Error fetching receipt count: $e');
  }
}



 int receiptCount = 0;
  String searchQuery = '';
  String? userName;


  @override
  void initState() {
    super.initState();
    _fetchReceiptCount();
     _fetchUserName();}
  







@override
void dispose() {
  // If you have any subscriptions or streams, cancel them here
  super.dispose();
}





  Future<void> _fetchUserName() async {
  // Example using Firebase Authentication
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (mounted) {  // Check if the widget is still mounted
      setState(() {
        userName = userData['name'] ?? 'User';
      });
    }
  } else {
    if (mounted) {  // Check if the widget is still mounted
      setState(() {
        userName = 'Guest';
      });
    }
  }
}

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                _header(),
                const SizedBox(height: 25),
                _search(),
                const SizedBox(height: 20),
                _cardOrder(),
                const SizedBox(height: 14),
                _category(context),
                const SizedBox(height: 14),
                _foodTrending(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _foodTrending(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Trending Now",
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('uploads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No trending items found.'));
          }

          final foodTrendings = snapshot.data!.docs
              .map((doc) =>
                  FoodTrending.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: foodTrendings.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final foodTrending = foodTrendings[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsPage(
                        imageUrl: foodTrending.imageUrl ?? '',
                        name: foodTrending.name ?? 'No Name',
                        review: foodTrending.review ?? 'No Review',
                        price: foodTrending.price ?? 0.0,
                        description: foodTrending.description,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 105,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: foodTrending.imageUrl ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        foodTrending.name ?? 'No Name',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${foodTrending.price != null ? (foodTrending.price as num).toStringAsFixed(0) : 'N/A'} frs',

                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ]);
  }

  Column _category(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Category List",
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopPage()),
                );
              },
              color: const Color(0xfff1f1ef),
              elevation: 0,
              height: 28,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Text(
                "View All",
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 90,
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('categories').snapshots(),
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
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemExtent: 100,
                itemBuilder: (context, index) {
                  var category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ItemListPage(categoryId: category.id),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: category['iconUrl'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, size: 30),
                            ),
                          ),
                        ),
                        Text(
                          category['name'],
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Row _header() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome,",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w400),
            ),
            Text(
              userName ?? 'Loading...',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReceiptPage()),
            );
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              const Icon(Iconsax.receipt, size: 28),
              if (receiptCount > 0) // Display badge only if there are receipts
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$receiptCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () async {
            final selectedValue = await showMenu<String>(
              context: context,
              position: const RelativeRect.fromLTRB(
                  100, 80, 0, 0), // Adjust position as needed
              items: [
                const PopupMenuItem<String>(
                  value: 'Add Item',
                  child: Text('Add Item'),
                ),
                const PopupMenuItem<String>(
                  value: 'Upload',
                  child: Text('Upload'),
                ),
                const PopupMenuItem<String>(
                  value: 'Full Page',
                  child: Text('Add Category'),
                ),
                                const PopupMenuItem<String>(
                  value: 'receipt',
                  child: Text('Manage Receipts'),
                ),
                const PopupMenuItem<String>(
                  value: 'items',
                  child: Text('Manage items'),
                ),
                const PopupMenuItem<String>(
                  value: 'trend',
                  child: Text('Manage Trends'),
                ),
              ],
            );

            // Navigate based on selected value
            if (selectedValue == 'Add Item') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemPage()),
              );
            } else if (selectedValue == 'Upload') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadPage()),
              );
            } else if (selectedValue == 'Full Page') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddCategoryPage()),
              );
            }else if (selectedValue == 'receipt') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageReceiptsPage()),
              );
            }else if (selectedValue == 'items') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageItemsPage()),
              );
            }
            else if (selectedValue == 'trend') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageUploadsPage()),
              );
            }
          },
          child: const Icon(Icons.menu, size: 28),
        ),
      ],
    );
  }

TextField _search() {
  return TextField(
    onChanged: (value) {
      setState(() {
        searchQuery = value;
      });
    },
    controller: searchController,
    decoration: InputDecoration(
    
      hintText: 'Search',
      hintStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
      filled: true,
      prefixIcon: const Icon(Iconsax.search_favorite),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      contentPadding: const EdgeInsets.all(14),
      suffixIcon: IconButton(
      
        icon: const Icon(Icons.search),
        onPressed: () {
          // Check that there is a search query and selected category
          if (searchQuery.isNotEmpty && selectedCategoryId != null) {
           
          } else {
            // Optionally show a message if no search query is provided
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search Not Active')),
            );
          }
        },
      ),
    ),
  );
}



  ClipRRect _cardOrder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            height: 144,
            width: double.infinity,
            child: Image.asset('assets/bg.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text(
                  'Order Food Online',
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover delicious food, fast and easy',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopPage()),
                    );
                  },
                  color: primaryColor,
                  elevation: 1,
                  height: 28,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Text(
                    "Order Now",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

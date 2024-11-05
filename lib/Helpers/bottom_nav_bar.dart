import 'package:faap/models/const.dart';
import 'package:faap/page/cart_page.dart';
import 'package:faap/page/home_page.dart';
import 'package:faap/page/profile_page.dart';
import 'package:faap/page/saved_page.dart';
import 'package:faap/page/shop_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 0;

  // Pages list for bottom navigation
  final List<Widget> _pages = [
    const MainPage(),
    const CartPage(), 
    const ShopPage(),
    const SavedPage(),
     const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[index], // Display the selected page
      bottomNavigationBar: _bottomBar(),
    );
  }

  // Bottom navigation bar setup
  BottomNavigationBar _bottomBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home, size: 28),
          activeIcon: Icon(Iconsax.home1, size: 28),
          label: 'Home',
          tooltip: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.shopping_bag, size: 28),
          activeIcon: Icon(Iconsax.shopping_bag1, size: 28),
          label: 'Cart',
          tooltip: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.shop, size: 28),
          activeIcon: Icon(Iconsax.shop1, size: 28),
          label: 'Shop',
          tooltip: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.lovely, size: 28),
          activeIcon: Icon(Iconsax.lovely5, size: 28),
          label: 'Saved',
          tooltip: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.user, size: 28),
          activeIcon: Icon(Iconsax.profile_add5, size: 28),
          label: 'Profile',
          tooltip: 'Profile',
        ),
      ],
      currentIndex: index,
      unselectedItemColor: Colors.grey,
      selectedItemColor:primaryColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      unselectedLabelStyle:
          GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
      selectedLabelStyle:
          GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
      onTap: (value) {
        setState(() {
          index = value;
        });
      },
    );
  }
}

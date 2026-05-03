// import 'package:flutter/material.dart';
// import '../constants.dart';
// import 'home_screen.dart';
// import 'category_screen.dart';
// import 'cart_screen.dart';
// import 'profile_screen.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//
//   // Industry standard: A list of dedicated widget screens
//   final List<Widget> _screens = const [
//     HomeScreen(),
//     CategoryScreen(),
//     CartScreen(),
//     ProfileScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _screens,
//       ), // IndexedStack preserves the state of each screen so you don't lose scroll position when switching tabs
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)
//             ]
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//           backgroundColor: Colors.white,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: AppColors.accentOrange,
//           unselectedItemColor: AppColors.primaryGreen.withOpacity(0.5),
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
//             BottomNavigationBarItem(icon: Icon(Icons.grid_view), activeIcon: Icon(Icons.grid_view_rounded), label: 'Categories'),
//             BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
//             BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart'; // ✅ 1. IMPORTED WISHLIST PROVIDER

import 'home_screen.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 2. Listen to BOTH the Cart and the Wishlist
    final int cartItemCount = context.watch<CartProvider>().itemCount;
    final int wishlistItemCount = context.watch<WishlistProvider>().items.length;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)
            ]
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.accentOrange,
          unselectedItemColor: AppColors.primaryGreen.withOpacity(0.5),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),

          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.grid_view), activeIcon: Icon(Icons.grid_view_rounded), label: 'Categories'),

            // ✅ 3. WRAPPED THE WISHLIST HEART IN A BADGE
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: wishlistItemCount > 0,
                label: Text(wishlistItemCount.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.accentOrange,
                child: const Icon(Icons.favorite_border),
              ),
              activeIcon: Badge(
                isLabelVisible: wishlistItemCount > 0,
                label: Text(wishlistItemCount.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.accentOrange,
                child: const Icon(Icons.favorite),
              ),
              label: 'Wishlist',
            ),

            // ✅ CART BADGE (Untouched)
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartItemCount > 0,
                label: Text(cartItemCount.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.accentOrange,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: cartItemCount > 0,
                label: Text(cartItemCount.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.accentOrange,
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),

            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_screen.dart';
import 'screens/login-screen.dart';
import 'screens/signup_screen.dart';
import 'screens/wishlist_screen.dart';
import 'constants.dart';

import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(
          create: (context) => ProductProvider()..fetchProducts(),
        ),
      ],
      child: const DomaApp(),
    ),
  );
}

class DomaApp extends StatelessWidget {
  const DomaApp({super.key});

  // This helper function handles the "Double-Fetch" logic at startup
  Future<void> _initializeApp(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);

    // 1. Check if we have a token and fetch the Profile
    await auth.checkAuthStatus();

    // 2. If the user is logged in, immediately fetch their backend cart
    if (auth.user != null) {
      await cart.fetchAndSyncCart(auth.user!.id);
      await wishlist.fetchWishlist(auth.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'DOMA - Design & Buy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundOffWhite,
        primaryColor: AppColors.primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          secondary: AppColors.accentOrange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // Use FutureBuilder to handle the startup logic
      home: FutureBuilder(
        future: _initializeApp(context),
        builder: (context, snapshot) {
          // While the app is "thinking" (checking token/cart)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            );
          }

          // After initialization, check if we have a user
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (auth.user != null) {
            return const MainScreen();
          }

          // If no user/token found, show Login
          return const LoginScreen();
        },
      ),

      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/wishlist': (context) => const WishlistScreen(),
      },
    );
  }
}
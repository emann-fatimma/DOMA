import 'package:doma/screens/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import 'screens/main_screen.dart';
import 'screens/login-screen.dart';
import 'screens/signup_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/payment/payment_cancel_screen.dart';
import 'screens/payment/payment_success_screen.dart';
import 'constants.dart';

import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/order_provider.dart';
import 'providers/review_provider.dart';

// ADD THIS — global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => ReviewProvider()),
      ],
      child: const DomaApp(),
    ),
  );
}

// CHANGE to StatefulWidget to handle deep links
class DomaApp extends StatefulWidget {
  const DomaApp({super.key});

  @override
  State<DomaApp> createState() => _DomaAppState();
}

class _DomaAppState extends State<DomaApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleDeepLinks();
  }

  void _handleDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      debugPrint("🔗 Deep link received: $uri");
      if (uri.scheme != 'doma') return;

      if (uri.host == 'payment') {
        if (uri.path == '/success') {
          final orderId = uri.queryParameters['orderId'] ?? '';
          navigatorKey.currentState?.pushNamed(
            '/payment-success',
            arguments: orderId,
          );
        } else if (uri.path == '/cancel') {
          navigatorKey.currentState?.pushNamed('/payment-cancel');
        }
      }
    });
  }

  Future<void> _initializeApp(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);

    await auth.checkAuthStatus();

    if (auth.user != null) {
      debugPrint("👤 User Detected: ${auth.user!.id}. Syncing data...");
      await cart.fetchAndSyncCart(auth.user!.id);
      await wishlist.fetchWishlist(auth.user!.id);
    } else {
      debugPrint("🚪 No user detected. Clearing provider memory.");
      wishlist.clearWishlist();
      cart.clearCartMemory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,  // ADD THIS
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
      home: FutureBuilder(
        future: _initializeApp(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            );
          }

          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (auth.user != null) {
            return const MainScreen();
          }

          return const LoginScreen();
        },
      ),
      routes: {
        '/home': (context) => const MainScreen(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/myOrders': (context) => const OrderHistoryScreen(),
        '/payment-success': (context) {
          final orderId = ModalRoute.of(context)!.settings.arguments as String? ?? '';
          return PaymentSuccessScreen(orderId: orderId);
        },
        '/payment-cancel': (context) => const PaymentCancelScreen(),
      },
    );
  }
}
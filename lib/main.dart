import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          surface: AppColors.backgroundOffWhite,
        ),
        textTheme: GoogleFonts.urbanistTextTheme().copyWith(
          displayLarge: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 8, color: AppColors.textDark),
          headlineLarge: GoogleFonts.urbanist(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark),
          headlineMedium: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
          titleLarge: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          titleMedium: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
          bodyLarge: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMid),
          bodyMedium: GoogleFonts.cormorantGaramond(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMid),
          labelLarge: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2, color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.urbanist(
            fontSize: 15, fontWeight: FontWeight.w900,
            letterSpacing: 5, color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
          labelStyle: GoogleFonts.urbanist(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 2, color: AppColors.primaryGreen,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.accentOrange,
          unselectedItemColor: AppColors.primaryGreen.withOpacity(0.5),
          selectedLabelStyle: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          unselectedLabelStyle: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w500),
          type: BottomNavigationBarType.fixed,
          elevation: 12,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
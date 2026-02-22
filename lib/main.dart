import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import provider
import 'screens/main_screen.dart';
import 'constants.dart';
import 'providers/cart_provider.dart'; // 2. Import your new cart provider

void main() {
  runApp(
    // 3. Wrap the app
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const DomaApp(),
    ),
  );
}

class DomaApp extends StatelessWidget {
  const DomaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const MainScreen(),
    );
  }
}
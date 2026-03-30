import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'screens/login-screen.dart';
import 'constants.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    // 3. Changed to MultiProvider to support both Cart and Auth
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
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
      // 4. Changed home to LoginScreen to start the Auth flow
      home: const LoginScreen(),
      // 5. Added routes for easy navigation after login
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

// Define the Google Sign In instance
final GoogleSignIn _googleSignIn = GoogleSignIn(
  // 🔥 CRITICAL: You must use the WEB Client ID here (the one in your Render .env)
  // This ensures an idToken is actually generated after you select an account.
  serverClientId: '926358609717-jlu8r8o2m56e3vpqa4qv3bb4me142330.apps.googleusercontent.com',
  scopes: [
    'email',
    'profile',
  ],
);

Future<void> signInWithGoogle(BuildContext context) async {
  // ✅ Show loading snackbar immediately
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Text("Signing in with Google..."),
        ],
      ),
      duration: Duration(seconds: 30), // long duration, we'll dismiss it manually
      behavior: SnackBarBehavior.floating,
    ),
  );

  try {
    print("Attempting Google Sign-In...");

    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // ✅ Dismiss on cancel
      print("User cancelled the Google Sign-In picker.");
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    print("Generated idToken: $idToken");

    if (idToken != null) {
      print("Sending token to Render backend...");

      final response = await http.post(
        Uri.parse('https://doma-backend.onrender.com/api/customer/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // ✅ Dismiss loader

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Backend Login Success! JWT: ${data['token']}");

        final auth = Provider.of<AuthProvider>(context, listen: false);
        final cart = Provider.of<CartProvider>(context, listen: false);
        final wishlist = Provider.of<WishlistProvider>(context, listen: false);

        final success = await auth.loginWithGoogle(
          data['token'],
          data['user'],
          cart: cart,
          wishlist: wishlist,
        );

        if (success && context.mounted) {
          // ✅ Show success snackbar briefly before navigating
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text("Signed in successfully!"),
                ],
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          await Future.delayed(const Duration(seconds: 1)); // let snackbar show
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        print("Backend Error (${response.statusCode}): ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google Sign-In failed. Please try again."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      print("Error: idToken was null. Check your SHA-1 fingerprints in Firebase.");
    }
  } catch (error) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // ✅ Dismiss on error
    print("Google Sign-In Exception: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $error"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
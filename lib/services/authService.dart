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
  try {
    print("Attempting Google Sign-In...");

    // 1. Show the Google Account Picker
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      print("User cancelled the Google Sign-In picker.");
      return;
    }

    // 2. Obtain the auth details (the idToken)
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    // Debug check: If this prints null, your SHA-1 or ClientID is wrong
    print("Generated idToken: $idToken");

    if (idToken != null) {
      print("Sending token to Render backend...");

      // 3. Send to your Render Backend
      final response = await http.post(
        Uri.parse('https://doma-backend.onrender.com/api/customer/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Backend Login Success! JWT: ${data['token']}");

        // ✅ Save token + fetch profile + sync cart & wishlist
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
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        print("Backend Error (${response.statusCode}): ${response.body}");
      }
    } else {
      print("Error: idToken was null. Check your SHA-1 fingerprints in Firebase.");
    }
  } catch (error) {
    // This will now catch and print the specific ApiException code (like 10 or 12500)
    print("Google Sign-In Exception: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $error")),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _wishlistItems = [];
  final _storage = const FlutterSecureStorage();
  String? _backendWishlistId;

  List<Product> get items => _wishlistItems;

  bool isFavorite(String productId) {
    return _wishlistItems.any((p) => p.id == productId);
  }

  // 1. Fetch Wishlist on Start
  Future<void> fetchWishlist(String userId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    // 🔥 FIX 1: Changed depth=1 to depth=2
    // This ensures the 'images' and 'vendor' inside the product are fully populated
    final url = Uri.parse('https://doma-backend.onrender.com/api/wishlists?where[customer][equals]=$userId&depth=2');

    try {
      final response = await http.get(url, headers: {'Authorization': 'JWT $token'});
      final data = jsonDecode(response.body);

      if (data['docs'] != null && data['docs'].isNotEmpty) {
        final wishDoc = data['docs'][0];
        _backendWishlistId = wishDoc['id'];

        final List remoteProducts = wishDoc['products'] ?? [];

        // Create a temporary list to prevent UI flickering during loop
        final List<Product> loadedProducts = [];

        for (var pData in remoteProducts) {
          // 🔥 FIX 2: Ensure pData is a Map (populated object) before parsing
          if (pData != null && pData is Map<String, dynamic>) {
            loadedProducts.add(Product.fromJson(pData));
          }
        }

        _wishlistItems.clear();
        _wishlistItems.addAll(loadedProducts);

        notifyListeners();
        debugPrint("💖 Wishlist Loaded: ${_wishlistItems.length} items.");
      }
    } catch (e) {
      debugPrint("❌ Wishlist Fetch Error: $e");
    }
  }

  // 2. Toggle Logic (Add/Remove)
  void toggleWishlist(Product product) {
    final index = _wishlistItems.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      _wishlistItems.removeAt(index);
    } else {
      // We add the full product object here (works for current session)
      _wishlistItems.add(product);
    }

    notifyListeners();
    _syncToBackend();
  }

  // 3. Sync to Render
  Future<void> _syncToBackend() async {
    if (_backendWishlistId == null) return;

    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('https://doma-backend.onrender.com/api/wishlists/$_backendWishlistId');

    // Your backend expects an array of product IDs
    final body = {
      'products': _wishlistItems.map((p) => p.id).toList(),
    };

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        debugPrint("✅ Wishlist synced to backend");
      }
    } catch (e) {
      debugPrint("❌ Wishlist Sync Error: $e");
    }
  }
}
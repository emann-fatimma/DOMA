import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final _storage = const FlutterSecureStorage();
  String? _backendCartId; // The unique ID of the Cart document in Payload

  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void clearCartMemory() {
    _items.clear();
    _backendCartId = null;
    notifyListeners();
    debugPrint("🧹 Cart Provider memory wiped for new session.");
  }

  // 1. Initial Fetch - Call this in MainScreen or after Login
  // Future<void> fetchCartFromBackend(String userId) async {
  //   final token = await _storage.read(key: 'jwt_token');
  //   if (token == null) return;
  //
  //   // Use filtering to find the cart assigned to this user
  //   final url = Uri.parse('https://doma-backend.onrender.com/api/carts?where[userId][equals]=$userId');
  //
  //   try {
  //     final response = await http.get(url, headers: {'Authorization': 'JWT $token'});
  //     final data = jsonDecode(response.body);
  //
  //     if (data['docs'] != null && data['docs'].isNotEmpty) {
  //       final cartDoc = data['docs'][0];
  //       _backendCartId = cartDoc['id']; // Store the ID for future PATCH requests
  //
  //       // Note: For a production FYP, you'd map the 'items' array here
  //       // to populate the local _items map.
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     debugPrint("Error fetching cart: $e");
  //   }
  // }
  Future<void> fetchAndSyncCart(String userId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    // Ensure depth=2 if your product has nested images/vendor info
    final url = Uri.parse('https://doma-backend.onrender.com/api/carts?where[userId][equals]=$userId&depth=2');

    try {
      final response = await http.get(url, headers: {'Authorization': 'JWT $token'});
      final data = jsonDecode(response.body);

      if (data['docs'] != null && data['docs'].isNotEmpty) {
        final cartDoc = data['docs'][0];
        _backendCartId = cartDoc['id'];

        final List remoteItems = cartDoc['items'] ?? [];

        // Create a temporary map to avoid flickering
        final Map<String, CartItem> loadedItems = {};

        for (var item in remoteItems) {
          if (item['product'] != null && item['product'] is Map) {
            // This is the critical part: Re-parsing the full product
            final product = Product.fromJson(item['product']);
            loadedItems[product.id] = CartItem(
                product: product,
                quantity: item['quantity'] ?? 1
            );
          }
        }

        _items.clear();
        _items.addAll(loadedItems);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Cart Fetch Error: $e");
    }
  }
  // 2. The Sync Logic - Pushes local state to Payload
  Future<void> _syncToBackend() async {
    if (_backendCartId == null) return;

    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('https://doma-backend.onrender.com/api/carts/$_backendCartId');

    // 🔥 CRITICAL: Ensure .id is a String and not being sent as a Map
    final body = {
      'items': _items.values.map((item) => {
        'product': item.product.id.toString(), // Force String
        'quantity': item.quantity,
      }).toList(),
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

      // ... rest of your logic
    } catch (e) {
      print("Sync Error: $e");
    }
  }// Helper to map backend JSON back into your Product-based CartItems
  void _updateLocalItemsFromBackend(List backendItems) {
    for (var item in backendItems) {
      final String pId = item['product']['id'] ?? item['product'];
      if (_items.containsKey(pId)) {
        _items[pId]!.quantity = item['quantity'];
      }
    }
    notifyListeners();
  }

  // --- Actions ---

  void addItem(Product product) {
    // 1. Check how many of this specific product we already have in the local cart
    final int inCartQty = _items[product.id]?.quantity ?? 0;

    // 2. THE GATEKEEPER CHECK
    // Compare what's in the cart vs. what's actually available in the Product model
    if (inCartQty >= product.quantity) {

      // 3. Trigger the Warning (Visual feedback for Aroosh)
      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text("Only ${product.quantity} items available in stock!"),
            ],
          ),
          backgroundColor: Colors.orange.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // ⛔ 4. STOP EVERYTHING.
      // Do not run notifyListeners() and do not run _syncToBackend().
      return;
    }

    // --- If we pass the Gatekeeper, we proceed as normal ---

    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
            (existing) => CartItem(product: existing.product, quantity: existing.quantity + 1),
      );
    } else {
      _items[product.id] = CartItem(product: product);
    }

    notifyListeners(); // Update the UI
    _syncToBackend();  // Sync to Render
  }
  void removeItem(String productId) {
    if (!_items.containsKey(productId)) return;

    _items.remove(productId);
    notifyListeners(); // Update UI immediately
    _syncToBackend();  // MUST call this to update Render
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
    } else {
      _items.update(
        productId,
            (existingItem) => CartItem(product: existingItem.product, quantity: newQuantity),
      );
      notifyListeners();
      _syncToBackend(); // Trigger sync
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _syncToBackend();
  }
}
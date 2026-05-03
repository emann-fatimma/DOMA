import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/cart_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure you import this

class OrderProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Function to place the order
  Future<Map<String, dynamic>> placeOrder({
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    required double tax,
    required double shippingCost,
    List<Map<String, dynamic>>? items, // Optional: if null, backend uses cart
  }) async {
    _isLoading = true;
    notifyListeners();

    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse(
        'https://doma-backend.onrender.com/api/customer/checkout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode({
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
          'paymentStatus': 'pending', // Default for COD
          'tax': tax,
          'shippingCost': shippingCost,
          if (items != null) 'items': items,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'order': data['order']};
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': data['error'] ?? 'Checkout failed',
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Add this to your OrderProvider class
  List<Map<String, dynamic>> _userOrders = [];

  List<Map<String, dynamic>> get userOrders => _userOrders;

  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    final token = await _storage.read(key: 'jwt_token');

    // 🔥 1. Use the CUSTOM route path (Notice the /user/ prefix)
    // Check your folder structure: if the folder is 'orders/user/[userId]',
    // the URL should look like this:
    final url = Uri.parse(
        'https://doma-backend.onrender.com/api/orders/user/$userId?depth=2'
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 🔥 2. MUST BE 'JWT' (The route.ts explicitly checks: scheme !== "JWT")
          'Authorization': 'JWT $token',
        },
      );

      debugPrint("📡 Fetching from CUSTOM route: $url");
      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📡 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 3. The route returns { success: true, docs: [...] }
        if (data['success'] == true) {
          _userOrders = List<Map<String, dynamic>>.from(data['docs']);
          debugPrint("📦 CUSTOM ROUTE SUCCESS! Orders: ${_userOrders.length}");
        }
      } else {
        debugPrint("❌ Route Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Connection Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    final token = await _storage.read(key: 'jwt_token');

    // Ensure this URL matches your backend folder structure exactly!
    final url = Uri.parse('https://doma-backend.onrender.com/api/orders/cancel/$orderId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token', // Matches your route.ts JWT scheme
        },
      );

      debugPrint("📡 Cancel Status: ${response.statusCode}");
      debugPrint("📡 Cancel Body: ${response.body}");

      if (response.statusCode == 200) {
        // Update the local list so the UI reflects 'canceled' immediately
        final index = _userOrders.indexWhere((order) => order['id'] == orderId);
        if (index != -1) {
          _userOrders[index]['orderStatus'] = 'canceled';
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        debugPrint("❌ Cancellation Failed: ${data['error']}");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("❌ Connection Error during cancellation: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool hasPurchasedProduct(String productId) {
    for (var order in _userOrders) {
      // Only count delivered or completed orders
      final status = order['orderStatus']?.toString() ?? '';
      if (status == 'canceled') continue;

      final items = order['items'] as List? ?? [];
      for (var item in items) {
        final product = item['product'];
        final String? id = product is Map
            ? product['id']?.toString()
            : product?.toString();
        if (id == productId) return true;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>> initiateSafepayPayment({
    required String orderId,
    required double amount,
  }) async {
    // 1. Define your base URL
    final String baseUrl = 'https://doma-backend.onrender.com';

    // 2. Retrieve your token securely (Assuming you use FlutterSecureStorage)
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      throw Exception("User not authenticated");
    }

    // 3. Make the request with defined variables
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/safepay/initiate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'JWT $token',
      },
      body: jsonEncode({
        'orderId': orderId,
        'amount': amount,
        'currency': 'PKR',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {'success': true, ...data};
    } else {
      throw Exception('Failed to initiate payment: ${response.body}');
    }
  }
}
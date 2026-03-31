import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user-model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://doma-backend.onrender.com/api/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token'];
        await _storage.write(key: 'jwt_token', value: token);

        // --- THE TRICK: IMMEDIATELY FETCH FULL PROFILE ---
        // This fills in the missing 'addresses' that login forgot
        await fetchProfile();

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Login error: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
  // Add this inside your AuthProvider class
  Future<void> fetchProfile() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://doma-backend.onrender.com/api/customer/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token', // Your backend logic needs this "JWT " prefix
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Update the existing _user with fresh data from the 'customer' key
          _user = UserModel.fromJson(data, token);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Profile fetch error: $e");
    }
  }

  Future<bool> updateFullProfile({
    required String name,
    required String phone,
    required List<Address> addresses
  }) async {
    final token = await _storage.read(key: 'jwt_token');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('https://doma-backend.onrender.com/api/customer/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode({
          'Name': name,
          'phone': phone,
          'addresses': addresses.map((a) => a.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserModel.fromJson(data['customer'], token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      // If we have a token, get the fresh profile (with addresses!) from the backend
      await fetchProfile();
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://doma-backend.onrender.com/api/customer/register'), // Make sure this matches your route path
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Name': name, // Capital 'N' as per your backend
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Success! Save the token and user data immediately
        final token = data['token'];
        await _storage.write(key: 'jwt_token', value: token);

        // Use our existing model to parse the user
        _user = UserModel.fromJson(data, token);

        _isLoading = false;
        notifyListeners();
        return null; // Return null for no error
      } else {
        _isLoading = false;
        notifyListeners();
        return data['error'] ?? "Registration failed";
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Connection error. Please try again.";
    }
  }

  Future<void> fetchCartFromBackend(String userId) async {
    final token = await _storage.read(key: 'jwt_token');

    // We filter the carts collection by the specific userId
    final url = Uri.parse(
        'https://doma-backend.onrender.com/api/carts?where[userId][equals]=$userId'
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Payload returns an object with a "docs" list
        if (data['docs'] != null && data['docs'].isNotEmpty) {
          final cartData = data['docs'][0]; // Get the first cart found
          final List items = cartData['items'] ?? [];

          // Update your local _items map here with the data from 'items'
          // ... loop through items and add to cart ...
          notifyListeners();
        }
      }
    } catch (e) {
      print("Fetch cart error: $e");
    }
  }

  void logout() async {
    _user = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
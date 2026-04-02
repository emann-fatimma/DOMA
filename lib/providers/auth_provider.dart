import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../models/user-model.dart';
import 'cart_provider.dart';
import 'wishlist_provider.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<bool> login(
      String email,
      String password,
      {required CartProvider cart, required WishlistProvider wishlist}
      ) async {
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

        // Fetch Profile First
        await fetchProfile();

        // 🔥 THE FIX: Trigger Cart and Wishlist sync IMMEDIATELY
        if (_user != null) {
          await cart.fetchAndSyncCart(_user!.id);
          await wishlist.fetchWishlist(_user!.id);
        }

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
          'Authorization': 'JWT $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['customer'] != null) {
          // 🔥 FIX: Pass data['customer'], NOT the whole 'data'
          _user = UserModel.fromJson(data['customer'], token!);
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

  Future<String?> register(
      String name,
      String email,
      String password,
      {required CartProvider cart, required WishlistProvider wishlist}
      ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://doma-backend.onrender.com/api/customer/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final token = data['token'];
        await _storage.write(key: 'jwt_token', value: token);

        _user = UserModel.fromJson(data, token);

        // 🔥 THE FIX: Fetch for new user immediately
        if (_user != null) {
          await cart.fetchAndSyncCart(_user!.id);
          await wishlist.fetchWishlist(_user!.id);
        }

        _isLoading = false;
        notifyListeners();
        return null;
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

// Inside AuthProvider class
  Future<Map<String, dynamic>> updateProfilePicture(XFile pickedFile) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return {'success': false, 'message': 'Not logged in'};

    try {
      // --- STEP 1: UPLOAD FILE TO MEDIA ---
      var uri = Uri.parse('https://doma-backend.onrender.com/api/upload/media');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'JWT $token'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          pickedFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var uploadData = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {'success': false, 'message': 'Upload failed'};
      }

      // The ID returned by your media upload route
      final String mediaId = uploadData['media']?['id']?.toString() ?? "";
      final profileUrl = Uri.parse('https://doma-backend.onrender.com/api/customer/profile');
      final profileResponse = await http.put(
        profileUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode({
          'avatar': mediaId,
        }),
      );

      if (profileResponse.statusCode == 200) {
        final updatedData = jsonDecode(profileResponse.body);

        // 🔥 CRITICAL: Update the local user object so the UI changes instantly
        if (updatedData['customer'] != null) {
          _user = UserModel.fromJson(updatedData['customer'], token!);
          notifyListeners();
        }

        return {'success': true, 'message': 'Profile picture updated!'};
      } else {
        return {'success': false, 'message': 'Failed to link profile picture'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  void logout() async {
    _user = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReviewProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _productReviews = [];
  List<Map<String, dynamic>> get productReviews => _productReviews;

  // --- FETCH REVIEWS FROM BACKEND ---
  Future<void> fetchReviewsForProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://doma-backend.onrender.com/api/reviews?where[product][equals]=$productId&depth=2'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _productReviews = List<Map<String, dynamic>>.from(data['docs']);
      }
    } catch (e) {
      debugPrint("❌ Error fetching reviews: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- SUBMIT NEW REVIEW ---
  Future<Map<String, dynamic>> submitReview({
    required String productId,
    required double rating,
    required String description,
    String? title,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('https://doma-backend.onrender.com/api/customer/reviews');

    try {
      // Create body map - conditionally add title to avoid backend "non-empty" error
      final Map<String, dynamic> requestBody = {
        'productId': productId,
        'rating': rating.toInt(),
        'description': description.trim(),
      };

      if (title != null && title.trim().isNotEmpty) {
        requestBody['title'] = title.trim();
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Refresh local list after successful post
        await fetchReviewsForProduct(productId);
        return {'success': true, 'message': 'Review posted successfully!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Failed to post review'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }



}
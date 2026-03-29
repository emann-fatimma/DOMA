import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  // Your live Payload endpoint
  static const String baseUrl = 'https://doma-backend.onrender.com/api';

  Future<List<Product>> fetchProducts() async {
    try {
      // ✅ ADD depth=2 HERE
      final response = await http.get(
        Uri.parse('$baseUrl/products?depth=2'),
      );

      print("🌐 API URL: ${response.request?.url}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> docs = data['docs'];

        return docs.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
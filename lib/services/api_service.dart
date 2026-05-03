// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/product_model.dart';
//
// class ApiService {
//   // Your live Payload endpoint
//   static const String baseUrl = 'https://doma-backend.onrender.com/api';
//
//   Future<List<Product>> fetchProducts() async {
//     try {
//       // ✅ ADD depth=2 HERE
//       final response = await http.get(
//         Uri.parse('$baseUrl/products?depth=2'),
//       );
//
//       // print("🌐 API URL: ${response.request?.url}");
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//
//         final List<dynamic> docs = data['docs'];
//
//         return docs.map((json) => Product.fromJson(json)).toList();
//       } else {
//         throw Exception(
//           'Failed to load products. Status Code: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/product_model.dart';

// class ApiService {
//   // Your live Payload endpoint
//   static const String baseUrl = 'https://doma-backend.onrender.com/api';

//   Future<List<Product>> fetchProducts() async {
//     try {
//       // ✅ ADD depth=2 HERE
//       final response = await http.get(
//         Uri.parse('$baseUrl/products?depth=2'),
//       );

//       // print("🌐 API URL: ${response.request?.url}");

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         final List<dynamic> docs = data['docs'];

//         return docs.map((json) => Product.fromJson(json)).toList();
//       } else {
//         throw Exception(
//           'Failed to load products. Status Code: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://doma-backend.onrender.com/api';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public-products?depth=2'),
      );

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

  // ✅ Add this
  Future<Product?> fetchProductBySlug(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public-products?where[slug][equals]=$slug&depth=2'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List<dynamic>;
        if (docs.isNotEmpty) {
          return Product.fromJson(docs[0]);
        }
      }
      return null;
    } catch (e) {
      print('❌ fetchProductBySlug error: $e');
      return null;
    }
  }
}
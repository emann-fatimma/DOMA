import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum RoomStyle {
  modern('modern', 'Modern'),
  minimalist('minimalist', 'Minimalist'),
  bohemian('bohemian', 'Bohemian'),
  scandinavian('scandinavian', 'Scandinavian'),
  industrial('industrial', 'Industrial'),
  contemporary('contemporary', 'Contemporary');

  const RoomStyle(this.label, this.displayName);
  final String label;
  final String displayName;
}

class RecommendedProduct {
  final String item;       // what the AI detected (e.g. "coffee table")
  final String name;       // actual product name from catalogue
  final int price;
  final String category;
  final String imageUrl;
  final String productId;
  final String shopUrl;
  final double score;

  RecommendedProduct({
    required this.item,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.productId,
    required this.shopUrl,
    required this.score,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      item:      json['item']      ?? '',
      name:      json['name']      ?? '',
      price:     json['price']     ?? 0,
      category:  json['category']  ?? '',
      imageUrl:  json['imageUrl']  ?? '',
      productId: json['productId'] ?? '',
      shopUrl:   json['shopUrl']   ?? '',
      score:     (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RedesignResult {
  final String imageUrl;
  final List<RecommendedProduct> products;

  RedesignResult({required this.imageUrl, required this.products});

  factory RedesignResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final imageData = data['redesignedImage'] as String;

    final rawProducts = data['matchedProducts']; // ← was 'products'
    final productList = (rawProducts is List)
        ? rawProducts
        .map((p) => RecommendedProduct.fromJson(p as Map<String, dynamic>))
        .toList()
        : <RecommendedProduct>[];

    return RedesignResult(imageUrl: imageData, products: productList);
  }
}

class DomaApiException implements Exception {
  final int statusCode;
  final String message;
  DomaApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'DomaApiException [$statusCode]: $message';
}

class DomaService {
  static const String _baseUrl = 'https://doma-ai.vercel.app/api/v1';

  Future<RedesignResult> redesignRoom({
    required File image,
    required RoomStyle style,
    String? customPrompt,
  }) async {
    final uri = Uri.parse('$_baseUrl/redesign');

    final bytes = await image.readAsBytes();
    final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    final body = {
      'style': style.label,
      'image': base64Image,
      if (customPrompt != null && customPrompt.trim().isNotEmpty)
        'prompt': customPrompt.trim(),
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 90));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      // Print all keys in data
      debugPrint('DATA KEYS: ${data.keys.toList()}');
      // Print raw products field
      debugPrint('PRODUCTS RAW: ${data['products']?.toString().substring(0, 200)}');
      return RedesignResult.fromJson(json);
    }

    throw DomaApiException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }
}
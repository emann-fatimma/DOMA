import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart'; // RagProduct lives here

class RagService {
  static const String _backendUrl = 'https://doma-backend.onrender.com';

  Future<Map<String, dynamic>> generate({
    required String prompt,
    List<Map<String, dynamic>> history = const [],
  }) async {
    final response = await http
        .post(
          Uri.parse('$_backendUrl/api/rag'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prompt': prompt,
            'useRAG': true,
            'history': history,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'result': data['result'] ?? '',
        'products': (data['products'] as List<dynamic>? ?? [])
            .map((p) => RagProduct.fromJson(p)) // ✅ RagProduct not Product
            .toList(),
      };
    } else {
      throw Exception('Failed: ${response.statusCode}');
    }
  }
}

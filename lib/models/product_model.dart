class Product {
  final String id;
  final String name;
  final String description;
  final num price;
  final String imageUrl;
  final bool isAvailable;
  final num rating;
  final String storeName;
  final String category;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.rating,
    required this.storeName,
    required this.category,
    required this.isFeatured,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] ?? {};
    final inventory = json['inventory'] ?? {};
    final ratingInfo = json['rating'] ?? {};

    String sName = 'Unknown Store';
    final vendorData = json['vendor'];
    if (vendorData is Map) {
      sName = vendorData['storeName']?.toString() ?? vendorData['name']?.toString() ?? vendorData['title']?.toString() ?? 'Store Name Missing';
    }

    String imgUrl = '';
    if (json['images'] != null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      final imageMedia = json['images'][0]['image'];
      if (imageMedia is Map && imageMedia['url'] != null) {
        String rawUrl = imageMedia['url'];
        imgUrl = rawUrl.startsWith('http') ? rawUrl : "https://doma-backend.onrender.com$rawUrl";
      }
    }

    // 🔥 ULTRA-SAFE CATEGORY EXTRACTOR
    String safeCategory = 'Uncategorized';
    try {
      final cat = json['category'];
      if (cat is Map) {
        safeCategory = cat['title']?.toString() ?? cat['name']?.toString() ?? 'Uncategorized';
      } else if (cat is List && cat.isNotEmpty && cat[0] is Map) {
        safeCategory = cat[0]['title']?.toString() ?? cat[0]['name']?.toString() ?? 'Uncategorized';
      } else if (cat is String) {
        // Only accept if it looks like a clean name (no JSON artifacts or timestamps)
        if (!cat.contains('{') &&
            !cat.contains('[') &&
            !cat.contains('CREATEDAT') &&
            !cat.contains('createdAt') &&
            !cat.contains(':') &&
            cat.trim().isNotEmpty) {
          safeCategory = cat;
        }
      }
    } catch (_) {
      // Fails silently and keeps 'Uncategorized'
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['title']?.toString() ?? 'Unknown Product',
      description: json['Description']?.toString() ?? '',
      price: pricing['price'] ?? 0,
      imageUrl: imgUrl,
      isAvailable: (inventory['quantity'] ?? 0) > 0,
      rating: ratingInfo['average'] ?? 0,
      storeName: sName,
      category: safeCategory,
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}

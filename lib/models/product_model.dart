class Product {
  final String id;
  final String name;
  final String description;
  final num price;
  final String imageUrl;
  final bool isAvailable;
  final num rating;
  final int reviewCount;
  final String storeName;
  final String category;
  final bool isFeatured;
  final int quantity;
  final String vendorId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
    required this.storeName,
    required this.category,
    required this.isFeatured,
    required this.quantity,
    required this.vendorId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] ?? {};
    final inventory = json['inventory'] ?? {};
    final ratingInfo = json['rating'] ?? {};

    // 🔥 EXTRACT VENDOR ID & STORE NAME
    String vId = "";
    String sName = 'Unknown Store';
    final vendorData = json['vendor'];

    if (vendorData != null) {
      if (vendorData is Map) {
        // If backend depth is 1+, we get the object
        vId = vendorData['id']?.toString() ?? "";
        sName =
            vendorData['storeName']?.toString() ??
            vendorData['name']?.toString() ??
            vendorData['title']?.toString() ??
            'Store Name Missing';
      } else {
        // If backend depth is 0, it's just the ID string
        vId = vendorData.toString();
      }
    }

    String imgUrl = '';
    if (json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      final firstImageEntry = json['images'][0];

      // Handling Payload Media structure (can be nested under 'image' or direct)
      final imageField = firstImageEntry is Map
          ? firstImageEntry['image']
          : null;

      if (imageField is Map && imageField['url'] != null) {
        String rawUrl = imageField['url'];
        imgUrl = rawUrl.startsWith('http')
            ? rawUrl
            : "https://doma-backend.onrender.com$rawUrl";
      } else if (imageField is String) {
        imgUrl = "https://doma-backend.onrender.com/media/$imageField";
      } else if (firstImageEntry is Map && firstImageEntry['url'] != null) {
        // Direct check if 'image' key isn't used
        String rawUrl = firstImageEntry['url'];
        imgUrl = rawUrl.startsWith('http')
            ? rawUrl
            : "https://doma-backend.onrender.com$rawUrl";
      }
    }

    String safeCategory = 'Uncategorized';
    try {
      final cat = json['category'];
      if (cat is Map) {
        safeCategory =
            cat['title']?.toString() ??
            cat['name']?.toString() ??
            'Uncategorized';
      } else if (cat is List && cat.isNotEmpty && cat[0] is Map) {
        safeCategory =
            cat[0]['title']?.toString() ??
            cat[0]['name']?.toString() ??
            'Uncategorized';
      }
    } catch (_) {}

    final int stockCount = (inventory['quantity'] is num)
        ? (inventory['quantity'] as num).toInt()
        : 0;

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['title']?.toString() ?? 'Unknown Product',
      description: json['Description']?.toString() ?? '',
      price: (pricing['price'] ?? 0).toDouble(), // Ensure double
      imageUrl: imgUrl,
      isAvailable: stockCount > 0,
      rating: (ratingInfo['average'] ?? 0).toDouble(),
      reviewCount: (ratingInfo['count'] is num)
          ? (ratingInfo['count'] as num).toInt()
          : 0,
      storeName: sName,
      vendorId: vId,
      category: safeCategory,
      isFeatured: json['isFeatured'] ?? false,
      quantity: stockCount,
    );
  }
}

// ============================================================
// RAG-specific models — used only by RagSearchScreen
// ============================================================

class RagProduct {
  final String id;
  final String productName;
  final String? productUrlSlug;
  final String? shortDescription;
  final double? price;
  final List<String> colors;
  final String? category;
  final double? score;

  RagProduct({
    required this.id,
    required this.productName,
    this.productUrlSlug,
    this.shortDescription,
    this.price,
    this.colors = const [],
    this.category,
    this.score,
  });

  factory RagProduct.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricingDetails'];
    return RagProduct(
      id: json['id']?.toString() ?? '',
      productName: json['productName'] ?? 'Unknown',
      productUrlSlug: json['productUrlSlug'],
      shortDescription: json['shortDescription'],
      price: (pricing?['discountedPrice'] ?? pricing?['originalPrice'])
          ?.toDouble(),
      colors: List<String>.from(json['colors'] ?? []),
      category: json['category'],
      score: json['score']?.toDouble(),
    );
  }
}

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final List<RagProduct> products;

  ChatMessage({
    required this.role,
    required this.content,
    this.products = const [],
  });
}

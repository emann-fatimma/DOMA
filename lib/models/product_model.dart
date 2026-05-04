class Product {
  final String id;
  final String name;
  final String description;
  final num price;
  final num? discountedPrice;
  final String imageUrl;
  final List<String> imageUrls;
  final bool isAvailable;
  final num rating;
  final int reviewCount;
  final String storeName;
  final String category;
  final bool isFeatured;
  final int quantity;
  final String vendorId;
  final String? model3dUrl;
  final String? model3dStatus;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice, // ✅ NEW (optional, so no breakage)
    required this.imageUrl,
    required this.imageUrls,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
    required this.storeName,
    required this.category,
    required this.isFeatured,
    required this.quantity,
    required this.vendorId,
    this.model3dUrl,
    this.model3dStatus,
  });

  /// ✅ Use this everywhere in UI instead of `price`
  num get effectivePrice => discountedPrice ?? price;

  /// ✅ Helpful for showing badges like "SALE"
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;

  bool get has3DModel =>
      model3dStatus == 'ready' && model3dUrl != null && model3dUrl!.isNotEmpty;

  factory Product.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] ?? {};
    final inventory = json['inventory'] ?? {};
    final ratingInfo = json['rating'] ?? {};

    String vId = "";
    String sName = 'Unknown Store';
    final vendorData = json['vendor'];
    if (vendorData != null) {
      if (vendorData is Map) {
        vId = vendorData['id']?.toString() ?? "";
        sName =
            vendorData['storeName']?.toString() ??
            vendorData['name']?.toString() ??
            vendorData['title']?.toString() ??
            'Store Name Missing';
      } else {
        vId = vendorData.toString();
      }
    }

    // ✅ Extract ALL images
    List<String> extractedUrls = [];
    if (json['images'] != null && json['images'] is List) {
      for (final entry in (json['images'] as List)) {
        String imgUrl = '';
        final imageField = entry is Map ? entry['image'] : null;

        if (imageField is Map && imageField['url'] != null) {
          String raw = imageField['url'];
          imgUrl = raw.startsWith('http')
              ? raw
              : "https://doma-backend.onrender.com$raw";
        } else if (imageField is String) {
          imgUrl = "https://doma-backend.onrender.com/media/$imageField";
        } else if (entry is Map && entry['url'] != null) {
          String raw = entry['url'];
          imgUrl = raw.startsWith('http')
              ? raw
              : "https://doma-backend.onrender.com$raw";
        }

        if (imgUrl.isNotEmpty) extractedUrls.add(imgUrl);
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
      price: (pricing['price'] ?? 0).toDouble(),

      // ✅ NEW FIELD (safe parsing)
      discountedPrice: pricing['discountedPrice'] != null
          ? (pricing['discountedPrice'] as num).toDouble()
          : null,

      imageUrl: extractedUrls.isNotEmpty ? extractedUrls.first : '',
      imageUrls: extractedUrls,
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
      model3dUrl: json['model3dUrl']?.toString(),
      model3dStatus: json['model3dStatus']?.toString(),
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

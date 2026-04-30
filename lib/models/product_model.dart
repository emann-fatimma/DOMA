class Product {
  final String id;
  final String name;
  final String description;
  final num price;
  final String imageUrl;       // keeps backward compat (first image)
  final List<String> imageUrls; // ✅ all images
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
    required this.imageUrls,   // ✅ add this
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

    String vId = "";
    String sName = 'Unknown Store';
    final vendorData = json['vendor'];
    if (vendorData != null) {
      if (vendorData is Map) {
        vId = vendorData['id']?.toString() ?? "";
        sName = vendorData['storeName']?.toString() ??
            vendorData['name']?.toString() ??
            vendorData['title']?.toString() ??
            'Store Name Missing';
      } else {
        vId = vendorData.toString();
      }
    }

    // ✅ Extract ALL images into a list
    List<String> extractedUrls = [];
    if (json['images'] != null && json['images'] is List) {
      for (final entry in (json['images'] as List)) {
        String imgUrl = '';
        final imageField = entry is Map ? entry['image'] : null;

        if (imageField is Map && imageField['url'] != null) {
          String raw = imageField['url'];
          imgUrl = raw.startsWith('http') ? raw : "https://doma-backend.onrender.com$raw";
        } else if (imageField is String) {
          imgUrl = "https://doma-backend.onrender.com/media/$imageField";
        } else if (entry is Map && entry['url'] != null) {
          String raw = entry['url'];
          imgUrl = raw.startsWith('http') ? raw : "https://doma-backend.onrender.com$raw";
        }

        if (imgUrl.isNotEmpty) extractedUrls.add(imgUrl);
      }
    }

    String safeCategory = 'Uncategorized';
    try {
      final cat = json['category'];
      if (cat is Map) {
        safeCategory = cat['title']?.toString() ?? cat['name']?.toString() ?? 'Uncategorized';
      } else if (cat is List && cat.isNotEmpty && cat[0] is Map) {
        safeCategory = cat[0]['title']?.toString() ?? cat[0]['name']?.toString() ?? 'Uncategorized';
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
      imageUrl: extractedUrls.isNotEmpty ? extractedUrls.first : '', // ✅ still works
      imageUrls: extractedUrls,                                       // ✅ full list
      isAvailable: stockCount > 0,
      rating: (ratingInfo['average'] ?? 0).toDouble(),
      reviewCount: (ratingInfo['count'] is num) ? (ratingInfo['count'] as num).toInt() : 0,
      storeName: sName,
      vendorId: vId,
      category: safeCategory,
      isFeatured: json['isFeatured'] ?? false,
      quantity: stockCount,
    );
  }
}
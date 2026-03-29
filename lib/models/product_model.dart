class Product {
  final String id;
  final String name;
  final String description;
  final num price;
  final String imageUrl;
  final bool isAvailable;
  final num rating;
  final String storeName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.rating,
    required this.storeName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    print("🔍 FULL PRODUCT JSON: $json");

    final pricing = json['pricing'] ?? {};
    final inventory = json['inventory'] ?? {};
    final ratingInfo = json['rating'] ?? {};

    // =========================
    // 🔥 VENDOR FIXED LOGIC
    // =========================
    String sName = 'Unknown Store';
    final vendorData = json['vendor'];

    print("🔍 RAW VENDOR DATA: $vendorData");

    if (vendorData is Map) {
      // ✅ Handle populated vendor object
      sName = vendorData['storeName']?.toString() ??
          vendorData['name']?.toString() ??
          vendorData['title']?.toString() ??
          vendorData['shopName']?.toString() ??
          vendorData['username']?.toString() ??
          'Store Name Missing';

      print("✅ Vendor object parsed. Store Name: $sName");

    } else if (vendorData is String) {
      // ❌ Backend did NOT populate relationship
      print("❌ Vendor is still ID (NO DEPTH): $vendorData");
      sName = 'Unknown Store';
    } else {
      print("⚠️ Vendor is NULL or unexpected format");
    }

    // =========================
    // 🖼 IMAGE FIXED LOGIC
    // =========================
    String imgUrl = '';

    if (json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {

      final imageMedia = json['images'][0]['image'];

      if (imageMedia is Map && imageMedia['url'] != null) {
        String rawUrl = imageMedia['url'];

        // ✅ Fix Cloudinary vs local uploads
        imgUrl = rawUrl.startsWith('http')
            ? rawUrl
            : "https://doma-backend.onrender.com$rawUrl";
      }
    }

    // =========================
    // 📦 FINAL OBJECT
    // =========================
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['title']?.toString() ?? 'Unknown Product',
      description: json['Description']?.toString() ?? '',
      price: pricing['price'] ?? 0,
      imageUrl: imgUrl,
      isAvailable: (inventory['quantity'] ?? 0) > 0,
      rating: ratingInfo['average'] ?? 0,
      storeName: sName,
    );
  }
}
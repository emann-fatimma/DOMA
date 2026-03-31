import 'dart:convert'; // 🔥 FIX: Required for jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 🔥 FIX: Required for network calls
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _allProducts = [];

  bool _isLoading = false;
  String _searchQuery = '';
  String _sortOption = 'Newest';

  // FILTER STATE
  double _minPrice = 0;
  double _maxPrice = 100000;
  bool _showAvailableOnly = false;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;

  // FILTER GETTERS
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get showAvailableOnly => _showAvailableOnly;

  // Dynamic max price based on actual products
  double get absoluteMaxPrice {
    if (_allProducts.isEmpty) return 100000;
    return _allProducts.map((p) => p.price.toDouble()).reduce((a, b) => a > b ? a : b);
  }

  // Check if any filter is active (for the orange badge)
  bool get isFilterActive => _showAvailableOnly || _minPrice > 0 || _maxPrice < absoluteMaxPrice;

  // 1. FEATURED PRODUCTS
  List<Product> get featuredProducts {
    return _allProducts.where((p) => p.isFeatured).toList();
  }

  // 2. CORE BROWSING (Search, Filter & Sort)
  List<Product> get displayedProducts {
    List<Product> filtered = List.from(_allProducts);

    // Search Logic
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Price Filter
    filtered = filtered.where((p) =>
    p.price >= _minPrice && p.price <= _maxPrice
    ).toList();

    // Availability Filter
    if (_showAvailableOnly) {
      filtered = filtered.where((p) => p.isAvailable).toList();
    }

    // Sort Logic
    if (_sortOption == 'Price: Low to High') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'Price: High to Low') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortOption == 'A-Z') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }

  // 3. FETCH BY CATEGORY (Backend Filter)
  Future<void> fetchProductsByCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    // Payload CMS syntax to filter products by category relationship ID
    final url = Uri.parse('https://doma-backend.onrender.com/api/products?where[category][equals]=$categoryId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List docs = data['docs'] ?? [];

        // 🔥 FIX: Update the master list so 'displayedProducts' can show them
        _allProducts = docs.map((json) => Product.fromJson(json)).toList();

        debugPrint("✅ Found ${_allProducts.length} products for category: $categoryId");
      }
    } catch (e) {
      debugPrint("❌ Category Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. GENERAL FETCH FROM PAYLOAD CMS
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allProducts = await ApiService().fetchProducts();
      // Set max price dynamically after fetch
      _maxPrice = absoluteMaxPrice;
    } catch (error) {
      debugPrint("Error fetching products: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(String option) {
    _sortOption = option;
    notifyListeners();
  }

  // FILTER METHODS
  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setAvailabilityFilter(bool value) {
    _showAvailableOnly = value;
    notifyListeners();
  }

  void clearFilters() {
    _minPrice = 0;
    _maxPrice = absoluteMaxPrice;
    _showAvailableOnly = false;
    // When clearing, you might want to fetch all products again
    fetchProducts();
  }
}
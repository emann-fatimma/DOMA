import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _allProducts = [];

  bool _isLoading = false;
  String _searchQuery = '';
  String _sortOption = 'Newest';

  // NEW: FILTER STATE
  double _minPrice = 0;
  double _maxPrice = 100000;
  bool _showAvailableOnly = false;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;

  // NEW: FILTER GETTERS
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get showAvailableOnly => _showAvailableOnly;

  // NEW: Dynamic max price based on actual products
  double get absoluteMaxPrice {
    if (_allProducts.isEmpty) return 100000;
    return _allProducts.map((p) => p.price.toDouble()).reduce((a, b) => a > b ? a : b);
  }

  // NEW: Check if any filter is active (for the orange badge)
  bool get isFilterActive => _showAvailableOnly || _minPrice > 0 || _maxPrice < absoluteMaxPrice;

  // 1. FEATURED PRODUCTS
  List<Product> get featuredProducts {
    return _allProducts.where((p) => p.isFeatured).toList();
  }

  // 2. CORE BROWSING (Search & Sort)
  List<Product> get displayedProducts {
    List<Product> filtered = _allProducts;

    // Search Logic
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // NEW: Price Filter
    filtered = filtered.where((p) =>
    p.price >= _minPrice && p.price <= _maxPrice
    ).toList();

    // NEW: Availability Filter
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

  // 3. FETCH FROM PAYLOAD CMS
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allProducts = await ApiService().fetchProducts();
      // NEW: Set max price dynamically after fetch
      _maxPrice = absoluteMaxPrice;
    } catch (error) {
      print("Error fetching products: $error");
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

  // NEW: FILTER METHODS
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
    notifyListeners();
  }
}
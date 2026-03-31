import 'package:flutter/material.dart';
import '../models/product_model.dart'; // Import your model

class CartItem {
  final Product product; // Changed from Map<String, dynamic>
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity; // Updated syntax
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
            (existingItem) => CartItem(product: existingItem.product, quantity: existingItem.quantity + 1),
      );
    } else {
      _items.putIfAbsent(
        product.id,
            () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
    } else {
      _items.update(
        productId,
            (existingItem) => CartItem(product: existingItem.product, quantity: newQuantity),
      );
      notifyListeners();
    }
  }
}
import 'package:flutter/material.dart';
import '../models/product_model.dart'; // 1. IMPORT YOUR NEW MODEL

// A small model to hold the product and how many the user wants
class CartItem {
  final Product product; // 2. CHANGED FROM Map<String, dynamic> TO Product
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  // The actual cart storage (maps product ID to the CartItem)
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      // 3. UPDATED TO OBJECT SYNTAX (cartItem.product.price)
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  // 4. CHANGED PARAMETER TO EXPECT A Product OBJECT
  void addItem(Product product) {
    // 5. UPDATED ALL product['id'] LOOKUPS TO product.id
    if (_items.containsKey(product.id)) {
      // If it's already in the cart, just increase the quantity
      _items.update(
        product.id,
            (existingItem) => CartItem(product: existingItem.product, quantity: existingItem.quantity + 1),
      );
    } else {
      // If it's new, add it to the cart
      _items.putIfAbsent(
        product.id,
            () => CartItem(product: product),
      );
    }
    notifyListeners(); // Tells the app to update the UI
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
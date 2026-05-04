// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../constants.dart';
// import '../providers/cart_provider.dart';
// import '../models/product_model.dart';
// import '../screens/product_detail_screen.dart';
//
// class CartScreen extends StatelessWidget {
//   const CartScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // We use context.watch to rebuild the screen whenever the cart changes
//     final cart = context.watch<CartProvider>();
//     final cartItems = cart.items;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundOffWhite,
//       appBar: AppBar(
//         title: const Text("My Cart"),
//         centerTitle: true,
//       ),
//
//       // ── EMPTY STATE ──
//       body: cartItems.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.shopping_cart_outlined,
//                 size: 100,
//                 color: Colors.grey.withAlpha(128)),
//             const SizedBox(height: 20),
//             const Text(
//               "Your cart is empty",
//               style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryGreen
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "Looks like you haven't added\nanything to your cart yet.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.popUntil(context, (route) => route.isFirst);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.accentOrange,
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text(
//                 "Start Shopping",
//                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             )
//           ],
//         ),
//       )
//
//       // ── FILLED STATE ──
//           : Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(15),
//               itemCount: cartItems.length,
//               itemBuilder: (context, index) {
//                 // 🔥 VARIABLES DEFINED INSIDE BUILDER SCOPE
//                 final productId = cartItems.keys.elementAt(index);
//                 final cartItem = cartItems.values.elementAt(index);
//
//                 final Product product = cartItem.product;
//                 final int qty = cartItem.quantity;
//                 final double price = product.price.toDouble();
//
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ProductDetailScreen(product: product),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: const [
//                         BoxShadow(color: Colors.black12, blurRadius: 5)
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         // Product Image
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: product.imageUrl.isNotEmpty
//                               ? Image.network(
//                               product.imageUrl,
//                               key: ValueKey(product.imageUrl), // Add this
//                               width: 70,
//                               height: 70,
//                               fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) =>
//                                 Container(
//                                     width: 70,
//                                     height: 70,
//                                     color: Colors.grey[200],
//                                     child: const Icon(Icons.broken_image, color: Colors.grey)
//                                 ),
//                           )
//                               : Container(
//                               width: 70,
//                               height: 70,
//                               color: Colors.grey[200],
//                               child: const Icon(Icons.image_not_supported, color: Colors.grey)
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//
//                         // Name + Price
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 product.name,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15,
//                                   color: AppColors.primaryGreen,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "Rs. ${(price * qty).toStringAsFixed(0)}",
//                                 style: const TextStyle(
//                                   color: AppColors.accentOrange,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // Qty Controls
//                         Row(
//                           children: [
//                             _qtyButton(
//                               icon: qty == 1 ? Icons.delete_outline : Icons.remove,
//                               onTap: () => cart.updateQuantity(productId, qty - 1),
//                               color: qty == 1 ? Colors.red : AppColors.primaryGreen,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 10),
//                               child: Text(
//                                 "$qty",
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             _qtyButton(
//                               icon: Icons.add,
//                               onTap: () {
//                                 // 🔥 INVENTORY WARNING CHECK
//                                 if (qty >= product.quantity) {
//                                   scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
//                                   scaffoldMessengerKey.currentState?.showSnackBar(
//                                     SnackBar(
//                                       content: Text("Only ${product.quantity} items available!"),
//                                       backgroundColor: Colors.orange.shade900,
//                                       behavior: SnackBarBehavior.floating,
//                                     ),
//                                   );
//                                 } else {
//                                   cart.updateQuantity(productId, qty + 1);
//                                 }
//                               },
//                               color: AppColors.primaryGreen,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // ── TOTAL + CHECKOUT BAR ──
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Total", style: TextStyle(color: Colors.grey)),
//                     Text(
//                       "Rs. ${cart.totalAmount.toStringAsFixed(0)}",
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.primaryGreen,
//                       ),
//                     ),
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     // TODO: Proceed to Checkout
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.accentOrange,
//                     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: const Text(
//                     "Checkout",
//                     style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _qtyButton({required IconData icon, required VoidCallback onTap, required Color color}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, size: 16, color: color),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../screens/product_detail_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use context.watch to rebuild the screen whenever the cart changes
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Text(
          "MY CART",
          style: GoogleFonts.urbanist(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      // ── EMPTY STATE ──
      body: cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 100,
                color: Colors.grey.withAlpha(128)),
            const SizedBox(height: 20),
            const Text(
              "Your cart is empty",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Looks like you haven't added\nanything to your cart yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Start Shopping",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      )

      // ── FILLED STATE ──
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                // 🔥 VARIABLES DEFINED INSIDE BUILDER SCOPE
                final productId = cartItems.keys.elementAt(index);
                final cartItem = cartItems.values.elementAt(index);

                final Product product = cartItem.product;
                final int qty = cartItem.quantity;
                final double price = product.price.toDouble();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B4332).withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  key: ValueKey(product.imageUrl),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 70,
                                        height: 70,
                                        color: const Color(0xFFEEE8DF),
                                        child: const Icon(Icons.broken_image, color: AppColors.textLight),
                                      ),
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: const Color(0xFFEEE8DF),
                                  child: const Icon(Icons.image_not_supported, color: AppColors.textLight),
                                ),
                        ),
                        const SizedBox(width: 12),

                        // Name + Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: GoogleFonts.urbanist(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rs. ${(price * qty).toStringAsFixed(0)}",
                                style: GoogleFonts.urbanist(
                                  color: AppColors.accentOrange,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Qty Controls
                        Row(
                          children: [
                            _qtyButton(
                              icon: qty == 1 ? Icons.delete_outline : Icons.remove,
                              onTap: () => cart.updateQuantity(productId, qty - 1),
                              color: qty == 1 ? Colors.red : AppColors.primaryGreen,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "$qty",
                                style: GoogleFonts.urbanist(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            _qtyButton(
                              icon: Icons.add,
                              onTap: () {
                                if (qty >= product.quantity) {
                                  scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                                  scaffoldMessengerKey.currentState?.showSnackBar(
                                    SnackBar(
                                      content: Text("Only ${product.quantity} items available!"),
                                      backgroundColor: Colors.orange.shade900,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  cart.updateQuantity(productId, qty + 1);
                                }
                              },
                              color: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── ORDER SUMMARY + CHECKOUT ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundOffWhite,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _summaryRow("Subtotal", "Rs. ${cart.totalAmount.toStringAsFixed(0)}"),
                      const SizedBox(height: 8),
                      _summaryRow("Delivery", "Calculated at checkout"),
                      Divider(color: AppColors.primaryGreen.withOpacity(0.10), height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            "Rs. ${cart.totalAmount.toStringAsFixed(0)}",
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      "CHECKOUT",
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    final bool isPlus = icon == Icons.add;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isPlus ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: isPlus ? Colors.white : color),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 15,
            color: AppColors.textMid,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
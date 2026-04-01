// import 'package:flutter/material.dart';
// import '../constants.dart'; // Import your hex codes
// import '../models/product_model.dart'; // 1. IMPORT YOUR NEW MODEL
// import '../screens/product_detail_screen.dart';
//
// class ProductCard extends StatelessWidget {
//   final Product product; // 2. CHANGE TYPE FROM Map TO Product
//
//   const ProductCard({super.key, required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     // print("FULL IMAGE PATH IS: ${product.imageUrl}"); // ADD THIS LINE
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProductDetailScreen(product: product),
//           ),
//         );
//       },
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 2,
//               blurRadius: 5,
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 3. UPDATED PRODUCT IMAGE (Fetches from the internet)
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//                 child: product.imageUrl.isNotEmpty
//                     ? Image.network(
//                     product.imageUrl.contains('https://res.cloudinary.com')
//                         ? product.imageUrl.split('https://doma-backend.onrender.com').last
//                         : product.imageUrl,
//                     fit: BoxFit.cover,
//                   width: double.infinity,
//                   // Shows a spinner while the image downloads from Render
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return const Center(child: CircularProgressIndicator());
//                   },
//                   // Shows a broken image icon if the URL fails
//                   errorBuilder: (context, error, stackTrace) {
//                     return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
//                   },
//                 )
//                     : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Note: I temporarily removed the 'category' text because
//                   // we didn't add category to the Product dart model earlier.
//                   // We can easily add it back later if you need it!
//
//                   // 4. PRODUCT NAME (Using object syntax)
//                   Text(
//                     product.name,
//                     style: const TextStyle(
//                       color: AppColors.primaryGreen,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   const SizedBox(height: 4),
//
//                   // 5. PRICE AND ADD BUTTON
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Rs. ${product.price}", // Using object syntax
//                         style: const TextStyle(
//                           color: AppColors.accentOrange,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: const BoxDecoration(
//                           color: AppColors.primaryGreen,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(Icons.add, color: Colors.white, size: 18),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ IMPORT PROVIDER
import '../constants.dart';
import '../models/product_model.dart';
import '../screens/product_detail_screen.dart';
import '../providers/wishlist_provider.dart'; // ✅ IMPORT WISHLIST PROVIDER

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    // ✅ Watch the wishlist provider to check if this specific product is favorited
    final wishlistProvider = context.watch<WishlistProvider>();
    final bool isFavorite = wishlistProvider.isFavorite(widget.product.id);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: widget.product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: widget.product.imageUrl.isNotEmpty
                    ? Image.network(
                  widget.product.imageUrl.contains('https://res.cloudinary.com')
                      ? widget.product.imageUrl.split('https://doma-backend.onrender.com').last
                      : widget.product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                  },
                )
                    : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. ${widget.product.price}",
                        style: const TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 🧡 CONNECTED HEART BUTTON
                      GestureDetector(
                        onTap: () {
                          // ✅ Calls your backend logic to add/remove from wishlist
                          wishlistProvider.toggleWishlist(widget.product);

                          // Optional: Show a little popup to confirm
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite ? "Removed from Wishlist" : "Added to Wishlist",
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                        child: Icon(
                          // ✅ UI automatically updates based on Provider state
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.accentOrange,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
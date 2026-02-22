// import 'package:flutter/material.dart';
// import '../constants.dart';
// import 'package:provider/provider.dart';
// import '../providers/cart_provider.dart';
//
// class ProductDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> product;
//
//   const ProductDetailScreen({super.key, required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     // Screen dimensions to make the image responsive
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundOffWhite,
//       // Transparent AppBar so the image flows underneath
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryGreen),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.favorite_border, color: AppColors.primaryGreen),
//             onPressed: () {},
//           ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // 1. TOP HALF: The massive product image
//           SizedBox(
//             height: size.height * 0.55,
//             width: double.infinity,
//             child: Image.asset(
//               product['image'],
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           // 2. BOTTOM HALF: The details container
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: size.height * 0.55, // Overlaps the image slightly
//               width: double.infinity,
//               padding: const EdgeInsets.all(25),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(40),
//                   topRight: Radius.circular(40),
//                 ),
//                 boxShadow: [
//                   BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
//                 ],
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Category and Rating
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           product['category'].toUpperCase(),
//                           style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2),
//                         ),
//                         Row(
//                           children: [
//                             const Icon(Icons.star, color: AppColors.accentOrange, size: 20),
//                             const SizedBox(width: 5),
//                             Text(
//                               product['rating'].toString(),
//                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//
//                     // Title
//                     Text(
//                       product['name'],
//                       style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Price and Stock Status
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Rs. ${product['price']}",
//                           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: product['isAvailable'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             product['isAvailable'] ? "In Stock" : "Out of Stock",
//                             style: TextStyle(
//                               color: product['isAvailable'] ? Colors.green : Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 25),
//
//                     // Description Placeholder
//                     const Text(
//                       "Description",
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
//                     ),
//                     const SizedBox(height: 10),
//                     const Text(
//                       "Elevate your space with this premium piece. Designed for both comfort and aesthetics, it seamlessly blends into modern interior layouts. Use the AR feature below to visualize it in your room before purchasing.",
//                       style: TextStyle(color: Colors.grey, height: 1.5),
//                     ),
//                     const SizedBox(height: 35),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//
//       // 3. BOTTOM NAVIGATION BAR: The Action Buttons
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
//         ),
//         child: Row(
//           children: [
//             // AR Button (Outlined)
//             Expanded(
//               flex: 1,
//               child: OutlinedButton(
//                 onPressed: () {
//                   // Will connect to Unity AR module later
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("AR Module initializing..."), backgroundColor: AppColors.primaryGreen),
//                   );
//                 },
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   side: const BorderSide(color: AppColors.primaryGreen, width: 2),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                 ),
//                 child: const Icon(Icons.view_in_ar, color: AppColors.primaryGreen, size: 28),
//               ),
//             ),
//             const SizedBox(width: 15),
//
//             // Add to Cart Button (Elevated)
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 onPressed: product['isAvailable'] ? () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("${product['name']} added to cart!"), backgroundColor: AppColors.accentOrange),
//                   );
//                 } : null, // Disables button if out of stock
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.accentOrange,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   "Add to Cart",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Screen dimensions to make the image responsive
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      // Transparent AppBar so the image flows underneath
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.primaryGreen),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // 1. TOP HALF: The massive product image
          SizedBox(
            height: size.height * 0.55,
            width: double.infinity,
            child: Image.asset(
              product['image'],
              fit: BoxFit.cover,
            ),
          ),

          // 2. BOTTOM HALF: The details container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.55, // Overlaps the image slightly
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['category'].toUpperCase(),
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.accentOrange, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              product['rating'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Title
                    Text(
                      product['name'],
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 5),

                    // Vendor Name (Dynamic)
                    Text(
                      "Sold by: ${product['vendor'] ?? 'DOMA'}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    // Price and Stock Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rs. ${product['price']}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: product['isAvailable'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product['isAvailable'] ? "In Stock" : "Out of Stock",
                            style: TextStyle(
                              color: product['isAvailable'] ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Dynamic Description
                    const Text(
                      "Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product['description'] ?? "No description available for this product.",
                      style: const TextStyle(color: Colors.grey, height: 1.5),
                    ),
                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. BOTTOM NAVIGATION BAR: The Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            // AR Button (Outlined)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  // Will connect to Unity AR module later
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("AR Module initializing..."), backgroundColor: AppColors.primaryGreen),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Icon(Icons.view_in_ar, color: AppColors.primaryGreen, size: 28),
              ),
            ),
            const SizedBox(width: 15),

            // Add to Cart Button (Elevated)
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: product['isAvailable'] ? () {
                  // 1. ADD ITEM TO THE CART PROVIDER
                  Provider.of<CartProvider>(context, listen: false).addItem(product);

                  // 2. SHOW SUCCESS MESSAGE
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${product['name']} added to cart!"), backgroundColor: AppColors.accentOrange),
                  );
                } : null, // Disables button if out of stock
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
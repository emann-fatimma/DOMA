import 'package:flutter/material.dart';
import '../constants.dart'; // Import your hex codes
import '../models/product_model.dart'; // 1. IMPORT YOUR NEW MODEL
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product; // 2. CHANGE TYPE FROM Map TO Product

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    print("FULL IMAGE PATH IS: ${product.imageUrl}"); // ADD THIS LINE
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
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
            // 3. UPDATED PRODUCT IMAGE (Fetches from the internet)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                    product.imageUrl.contains('https://res.cloudinary.com')
                        ? product.imageUrl.split('https://doma-backend.onrender.com').last
                        : product.imageUrl,
                    fit: BoxFit.cover,
                  width: double.infinity,
                  // Shows a spinner while the image downloads from Render
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  // Shows a broken image icon if the URL fails
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
                  // Note: I temporarily removed the 'category' text because
                  // we didn't add category to the Product dart model earlier.
                  // We can easily add it back later if you need it!

                  // 4. PRODUCT NAME (Using object syntax)
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // 5. PRICE AND ADD BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. ${product.price}", // Using object syntax
                        style: const TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
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
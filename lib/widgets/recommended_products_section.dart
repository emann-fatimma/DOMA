import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../constants.dart';
import '../screens/product_detail_screen.dart';

class RecommendedProductsSection extends StatelessWidget {
  final Product currentProduct;

  const RecommendedProductsSection({super.key, required this.currentProduct});

  @override
  Widget build(BuildContext context) {
    // 1. Access the master list using the new 'products' getter
    final allProducts = Provider.of<ProductProvider>(context).products;

    // 2. 🔥 THE CATEGORY LOGIC: Same category, but not the SAME product
    final recommendations = allProducts.where((p) =>
    p.category == currentProduct.category && p.id != currentProduct.id
    ).toList();

    // If there's nothing else in this category, don't show the section
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "More in this Category",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final item = recommendations[index];
              return _buildRecommendationCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Product item) {
    return GestureDetector(
      onTap: () {
        // Use pushReplacement so the "Back" button takes them to the SHOP,
        // not back through every single product they clicked.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: item)),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(item.imageUrl, height: 130, width: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text("Rs. ${item.price}",
                style: const TextStyle(color: AppColors.accentOrange, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
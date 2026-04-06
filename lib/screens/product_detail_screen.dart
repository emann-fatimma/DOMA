import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';
import 'rate_review_screen.dart';
import '../providers/review_provider.dart';
import 'vendor_store_screen.dart';
import '../widgets/recommended_products_section.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // 🔥 TRIGGER FETCH: Get data as soon as the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false)
          .fetchReviewsForProduct(product.id);
    });

    final wishlist = context.watch<WishlistProvider>();
    final size = MediaQuery.of(context).size;
    final bool isSaved = wishlist.isFavorite(product.id);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
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
            icon: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: AppColors.accentOrange,
            ),
            onPressed: () => wishlist.toggleWishlist(product),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // 1. TOP HALF: Image
          SizedBox(
            height: size.height * 0.55,
            width: double.infinity,
            child: product.imageUrl.isNotEmpty
                ? Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            )
                : Container(color: Colors.grey[200]),
          ),

          // 2. BOTTOM HALF: Details container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.55,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(product),
                    const SizedBox(height: 15),
                    _buildTitleAndPrice(product,context),
                    const SizedBox(height: 20),
                    _buildDescription(product),
                    const SizedBox(height: 30),

                    // --- RATINGS & REVIEWS SECTION ---
                    _buildReviewHeader(context, product),
                    const SizedBox(height: 15),
                    _buildRatingSummary(product),
                    const SizedBox(height: 25),

                    // 🔥 DYNAMIC REVIEWS LIST
                    Consumer<ReviewProvider>(
                      builder: (context, revProvider, child) {
                        if (revProvider.isLoading && revProvider.productReviews.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(color: AppColors.primaryGreen),
                            ),
                          );
                        }

                        if (revProvider.productReviews.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No reviews yet. Be the first to review!",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return Column(
                          children: revProvider.productReviews.map((review) {
                            final customer = review['customer'];
                            String displayName = "Verified User";
                            String? avatarUrl;

                            if (customer is Map) {
                              // Get Name (Matching the capital 'Name' field in your backend)
                              displayName = customer['Name']?.toString() ??
                                  customer['name']?.toString() ??
                                  "Verified Customer";

                              // Get Avatar URL (Nested inside Media object via Depth 2)
                              if (customer['avatar'] != null && customer['avatar'] is Map) {
                                avatarUrl = customer['avatar']['url'];
                              }
                            }

                            return _buildReviewItem(
                              displayName,
                              (review['rating'] as num).toInt(),
                              review['description'] ?? "",
                              review['createdAt']?.toString().substring(0, 10) ?? "Recent",
                              avatarUrl: avatarUrl,
                              isVerified: review['verifiedPurchase'] ?? false,
                            );
                          }).toList(),
                        );
                      },

                    ),
                    const SizedBox(height: 120),
                    RecommendedProductsSection(currentProduct: product),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, product),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(product.category.toUpperCase(),
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.accentOrange, size: 18),
            const SizedBox(width: 5),
            Text(product.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _buildTitleAndPrice(Product product, BuildContext context) { // 🔥 Added context
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),

        // --- STORE BUTTON START ---
        Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 5),
            Text("Sold by: ${product.storeName}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Extract vendor ID - adjust based on your Product model structure
                final String? vendorId = product.vendorId;

                if (vendorId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorStoreScreen(
                        vendorId: vendorId,
                        vendorName: product.storeName,
                      ),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
              child: const Row(
                children: [
                  Text("Visit Store", style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.accentOrange),
                ],
              ),
            ),
          ],
        ),
        // --- STORE BUTTON END ---

        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Rs. ${product.price}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
            _buildStockBadge(product.isAvailable),
          ],
        ),
      ],
    );
  }
  Widget _buildDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(product.description, style: const TextStyle(color: Colors.grey, height: 1.5)),
      ],
    );
  }

  Widget _buildReviewHeader(BuildContext context, Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Ratings & Reviews",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
        ),
        TextButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RateReviewScreen(
                  productId: product.id,
                  productTitle: product.name,
                ),
              ),
            );
            if (context.mounted) {
              Provider.of<ReviewProvider>(context, listen: false)
                  .fetchReviewsForProduct(product.id);
            }
          },
          child: const Text(
            "Write a Review",
            style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSummary(Product product) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.backgroundOffWhite,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) => Icon(
                    i < product.rating.floor() ? Icons.star : Icons.star_border,
                    color: AppColors.accentOrange, size: 14)),
              ),
              const SizedBox(height: 5),
              Text("${product.reviewCount} Reviews", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              children: [
                _buildStatBar(5, 0.8),
                _buildStatBar(4, 0.15),
                _buildStatBar(3, 0.05),
                _buildStatBar(2, 0.0),
                _buildStatBar(1, 0.0),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatBar(int star, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$star", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: val,
              backgroundColor: Colors.grey[300],
              color: AppColors.accentOrange,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, int stars, String comment, String date, {String? avatarUrl, bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with Initials fallback
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(name[0].toUpperCase(), style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (isVerified) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.verified, color: Colors.blue, size: 14),
                            ],
                          ],
                        ),
                        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: AppColors.accentOrange,
                        size: 14,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 52), // Aligns text under the name
            child: Text(
              comment,
              style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
            ),
          ),
          const Divider(height: 40),
        ],
      ),
    );
  }

  Widget _buildStockBadge(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: available ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(available ? "In Stock" : "Out of Stock", style: TextStyle(color: available ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () {}, child: const Icon(Icons.view_in_ar, color: AppColors.primaryGreen))),
          const SizedBox(width: 15),
          Expanded(flex: 2, child: ElevatedButton(
            onPressed: product.isAvailable ? () {
              context.read<CartProvider>().addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${product.name} added!"), backgroundColor: AppColors.accentOrange));
            } : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
            child: const Text("Add to Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }
}
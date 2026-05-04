import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';
import 'rate_review_screen.dart';
import '../providers/review_provider.dart';
import 'vendor_store_screen.dart';
import '../widgets/recommended_products_section.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import 'ar_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // minChildSize = 0.08 → only the drag handle peeks up, full image visible
  static const double _minChildSize = 0.08;
  static const double _maxChildSize = 0.92;
  static const double _initialChildSize = 0.52;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(
        context,
        listen: false,
      ).fetchReviewsForProduct(widget.product.id);
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).fetchUserOrders(auth.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final size = MediaQuery.of(context).size;
    final bool isSaved = wishlist.isFavorite(widget.product.id);
    final List<String> images = widget.product.imageUrls;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _appBarButton(
          icon: Icons.arrow_back_ios_new,
          color: AppColors.primaryGreen,
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          _appBarButton(
            icon: isSaved ? Icons.favorite : Icons.favorite_border,
            color: AppColors.accentOrange,
            onTap: () => wishlist.toggleWishlist(widget.product),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          // ── BEAUTIFUL IMAGE CAROUSEL ──────────────────────
          SizedBox(
            height: size.height,
            width: double.infinity,
            child: Stack(
              children: [
                // Main image with soft background
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: images.isNotEmpty
                      ? Container(
                          key: ValueKey(_currentImageIndex),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0EB), // warm cream bg
                          ),
                          child: Image.network(
                            images[_currentImageIndex],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),

                // Subtle vignette overlay (bottom fade into sheet)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * _initialChildSize + 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.white, Colors.white.withOpacity(0.0)],
                        stops: const [0.0, 0.45],
                      ),
                    ),
                  ),
                ),

                // Top gradient for AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── THUMBNAIL STRIP ──
                if (images.length > 1)
                  Positioned(
                    bottom: size.height * _initialChildSize + 18,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: images.length,
                        itemBuilder: (context, i) {
                          final bool active = i == _currentImageIndex;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 10),
                              width: active ? 56 : 48,
                              height: active ? 56 : 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: active
                                      ? AppColors.accentOrange
                                      : Colors.white.withOpacity(0.6),
                                  width: active ? 2.5 : 1.5,
                                ),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accentOrange
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 4,
                                        ),
                                      ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  images[i],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.grey[200]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // ── PAGE VIEW (invisible, just for swipe gesture) ──
                if (images.length > 1)
                  Positioned.fill(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) =>
                          setState(() => _currentImageIndex = i),
                      itemBuilder: (_, __) => const SizedBox.shrink(),
                    ),
                  ),

                // ── ELEGANT PILL COUNTER ──
                if (images.length > 1)
                  Positioned(
                    top: 100,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${_currentImageIndex + 1} / ${images.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── DRAGGABLE DETAIL SHEET ──────────────────────────
          DraggableScrollableSheet(
            initialChildSize: _initialChildSize,
            minChildSize: _minChildSize,
            maxChildSize: _maxChildSize,
            snap: true,
            snapSizes: const [_minChildSize, _initialChildSize, _maxChildSize],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Drag handle ──
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 20),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0D8CC),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(widget.product),
                            const SizedBox(height: 12),
                            _buildTitleAndPrice(widget.product, context),
                            const SizedBox(height: 22),
                            _buildDescription(widget.product),
                            const SizedBox(height: 24),
                            Divider(
                              color: Colors.grey.shade100,
                              thickness: 1.5,
                            ),
                            const SizedBox(height: 20),
                            _buildReviewHeader(context, widget.product),
                            const SizedBox(height: 16),
                            _buildRatingSummary(),
                            const SizedBox(height: 20),
                            _buildReviewsList(),
                            const SizedBox(height: 24),
                            RecommendedProductsSection(
                              currentProduct: widget.product,
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, widget.product),
    );
  }

  // ── APPBAR BUTTON ───────────────────────────────────────────
  Widget _appBarButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 19),
        onPressed: onTap,
      ),
    );
  }

  // ── CATEGORY + RATING ───────────────────────────────────────
  Widget _buildHeader(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product.category.toUpperCase(),
            style: GoogleFonts.urbanist(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.accentOrange,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  // ── TITLE, STORE & PRICE ────────────────────────────────────
  Widget _buildTitleAndPrice(Product product, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: GoogleFonts.urbanist(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 15, color: Colors.grey),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                "Sold by: ${product.storeName}",
                style: GoogleFonts.cormorantGaramond(
                  color: AppColors.textLight,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (product.vendorId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VendorStoreScreen(
                        vendorId: product.vendorId,
                        vendorName: product.storeName,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.accentOrange.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      "Visit Store",
                      style: TextStyle(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.accentOrange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// ✅ UPDATED PRICE BLOCK
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Price",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                if (product.hasDiscount) ...[
                  Text(
                    "Rs. ${product.price}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    "Rs. ${product.discountedPrice}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ] else
                  Text(
                    "Rs. ${product.price}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentOrange,
                    ),
                  ),
              ],
            ),

            _buildStockBadge(product.isAvailable),
          ],
        ),
      ],
    );
  }

  // ── DESCRIPTION ─────────────────────────────────────────────
  Widget _buildDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 14),
        ),
      ],
    );
  }

  // ── REVIEW HEADER ───────────────────────────────────────────
  Widget _buildReviewHeader(BuildContext context, Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Ratings & Reviews",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            final hasPurchased = orderProvider.hasPurchasedProduct(product.id);
            return GestureDetector(
              onTap: () async {
                if (!hasPurchased) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "You can only review products you have purchased.",
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RateReviewScreen(
                      productId: product.id,
                      productTitle: product.name,
                    ),
                  ),
                );
                if (context.mounted) {
                  Provider.of<ReviewProvider>(
                    context,
                    listen: false,
                  ).fetchReviewsForProduct(product.id);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: hasPurchased
                      ? AppColors.accentOrange
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Write a Review",
                  style: TextStyle(
                    color: hasPurchased ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── RATING SUMMARY ──────────────────────────────────────────
  Widget _buildRatingSummary() {
    return Consumer<ReviewProvider>(
      builder: (context, revProvider, child) {
        final reviews = revProvider.productReviews;
        final total = reviews.length;
        Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
        for (var r in reviews) {
          final rating = (r['rating'] as num?)?.toInt() ?? 0;
          if (counts.containsKey(rating)) counts[rating] = counts[rating]! + 1;
        }
        double avg = 0;
        if (total > 0) {
          avg = counts.entries.fold(0, (a, e) => a + e.key * e.value) / total;
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.backgroundOffWhite,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    total > 0 ? avg.toStringAsFixed(1) : "0.0",
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < avg.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.accentOrange,
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$total Reviews",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final double val = total > 0
                        ? (counts[star]! / total)
                        : 0.0;
                    return _buildStatBar(star, val);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBar(int star, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$star",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.star_rounded,
            color: AppColors.accentOrange,
            size: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: val,
                backgroundColor: Colors.grey[200],
                color: AppColors.accentOrange,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              "${(val * 100).toInt()}%",
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ── REVIEWS LIST ────────────────────────────────────────────
  Widget _buildReviewsList() {
    return Consumer<ReviewProvider>(
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
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundOffWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No reviews yet. Be the first!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: revProvider.productReviews.map((review) {
            final customer = review['customer'];
            String displayName = "Verified User";
            String? avatarUrl;
            if (customer is Map) {
              displayName =
                  customer['Name']?.toString() ??
                  customer['name']?.toString() ??
                  "Verified Customer";
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
    );
  }

  Widget _buildReviewItem(
    String name,
    int stars,
    String comment,
    String date, {
    String? avatarUrl,
    bool isVerified = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundOffWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.accentOrange,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comment,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── STOCK BADGE ─────────────────────────────────────────────
  Widget _buildStockBadge(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: available
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: available
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 13,
            color: available ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            available ? "In Stock" : "Out of Stock",
            style: TextStyle(
              color: available ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAV BAR ──────────────────────────────────────────
  Widget _buildBottomNavBar(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // AR Button — only active if product has a 3D model
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              border: Border.all(
                color: product.has3DModel
                    ? AppColors.primaryGreen.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Tooltip(
              message: product.has3DModel
                  ? 'View in AR'
                  : '3D model not available',
              child: IconButton(
                onPressed: product.has3DModel
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ARScreen(
                              productId: product.id,
                              productName: product.name,
                            ),
                          ),
                        );
                      }
                    : null,
                icon: Icon(
                  Icons.view_in_ar,
                  color: product.has3DModel
                      ? AppColors.primaryGreen
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Add to Cart button (unchanged)
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: product.isAvailable
                    ? () {
                        context.read<CartProvider>().addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${product.name} added to cart!"),
                            backgroundColor: AppColors.accentOrange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "ADD TO CART",
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

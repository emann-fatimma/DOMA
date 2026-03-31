import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';
import '../constants.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openFilterSheet(BuildContext context, ProductProvider productProvider) {
    // Local temp values so changes only apply when user taps Apply
    double tempMin = productProvider.minPrice;
    double tempMax = productProvider.maxPrice;
    bool tempAvailableOnly = productProvider.showAvailableOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Products",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          productProvider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Clear All",
                          style: TextStyle(color: AppColors.accentOrange),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // PRICE RANGE
                  const Text(
                    "Price Range",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. ${tempMin.toInt()}",
                        style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rs. ${tempMax.toInt()}",
                        style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(tempMin, tempMax),
                    min: 0,
                    max: productProvider.absoluteMaxPrice,
                    divisions: 100,
                    activeColor: AppColors.primaryGreen,
                    inactiveColor: AppColors.primaryGreen.withOpacity(0.2),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        tempMin = values.start;
                        tempMax = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // AVAILABILITY TOGGLE
                  const Text(
                    "Availability",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Show available items only",
                        style: TextStyle(color: AppColors.textLight, fontSize: 14),
                      ),
                      Switch(
                        value: tempAvailableOnly,
                        activeColor: AppColors.primaryGreen,
                        onChanged: (value) {
                          setModalState(() {
                            tempAvailableOnly = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // APPLY BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        productProvider.setPriceRange(tempMin, tempMax);
                        productProvider.setAvailabilityFilter(tempAvailableOnly);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text(
          "DOMA - Design & Buy",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // 1. SEARCH BAR + FILTER BUTTON
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    child: Row(
                      children: [
                        // Search Bar
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (value) => productProvider.search(value),
                              decoration: const InputDecoration(
                                hintText: "Search furniture, decor...",
                                prefixIcon: Icon(Icons.search, color: AppColors.primaryGreen),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Filter Button with badge
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.tune, color: Colors.white),
                                onPressed: () => _openFilterSheet(context, productProvider),
                              ),
                            ),
                            // Orange dot when filter is active
                            if (productProvider.isFilterActive)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ==========================================
                  // 2. LOADING STATE
                  // ==========================================
                  if (productProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primaryGreen),
                      ),
                    )

                  // ==========================================
                  // 3. EMPTY STATE
                  // ==========================================
                  else if (productProvider.displayedProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Center(
                        child: Text(
                          "No products found.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )

                  // ==========================================
                  // 4. THE ACTUAL FEED
                  // ==========================================
                  else ...[
                      // FEATURED ROW
                      if (productProvider.searchQuery.isEmpty &&
                          productProvider.featuredProducts.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                          child: Text(
                            "Featured",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            scrollDirection: Axis.horizontal,
                            itemCount: productProvider.featuredProducts.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ProductCard(
                                  product: productProvider.featuredProducts[index],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // SORTING DROPDOWN
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              productProvider.searchQuery.isNotEmpty
                                  ? "Search Results"
                                  : "All Products",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            DropdownButton<String>(
                              value: productProvider.sortOption,
                              icon: const Icon(Icons.sort, size: 18, color: AppColors.primaryGreen),
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              underline: const SizedBox(),
                              onChanged: (String? newValue) {
                                if (newValue != null) productProvider.setSortOption(newValue);
                              },
                              items: <String>[
                                'Newest',
                                'Price: Low to High',
                                'Price: High to Low',
                                'A-Z'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PRODUCT GRID
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: productProvider.displayedProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.70,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: productProvider.displayedProducts[index],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
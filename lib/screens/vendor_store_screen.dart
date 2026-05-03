import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart'; // Make sure this path matches your ProductCard location

class VendorStoreScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;

  const VendorStoreScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<VendorStoreScreen> createState() => _VendorStoreScreenState();
}

class _VendorStoreScreenState extends State<VendorStoreScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 Fetch only this vendor's products on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProductsByVendor(widget.vendorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Text(widget.vendorName),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- VENDOR HEADER INFO ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.storefront, size: 40, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.vendorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${productProvider.vendorProducts.length} Products Available",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // --- PRODUCT GRID ---
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : productProvider.vendorProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72, // Adjust based on your ProductCard height
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: productProvider.vendorProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: productProvider.vendorProducts[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text(
            "This store is empty for now.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
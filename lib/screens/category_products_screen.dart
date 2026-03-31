// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/product_provider.dart';
// import '../widgets/product_card.dart';
// import '../constants.dart';
//
// class CategoryProductsScreen extends StatelessWidget {
//   final String categoryName;
//
//   const CategoryProductsScreen({super.key, required this.categoryName});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(categoryName),
//         centerTitle: true,
//         backgroundColor: AppColors.primaryGreen,
//       ),
//       body: Consumer<ProductProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (provider.displayedProducts.isEmpty) {
//             return const Center(child: Text("No products found in this category."));
//           }
//
//           return GridView.builder(
//             padding: const EdgeInsets.all(15),
//             itemCount: provider.displayedProducts.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.75,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemBuilder: (context, index) {
//               return ProductCard(product: provider.displayedProducts[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
// }
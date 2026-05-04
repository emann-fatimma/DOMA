// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import '../constants.dart';
// import '../providers/product_provider.dart';
//
// class CategoryScreen extends StatelessWidget {
//   const CategoryScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundOffWhite,
//       appBar: AppBar(
//         title: const Text(
//           "All Categories",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: FutureBuilder(
//         // Fetch categories from Payload CMS
//         future: http.get(Uri.parse('https://doma-backend.onrender.com/api/categories')),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: AppColors.primaryGreen),
//             );
//           }
//
//           if (snapshot.hasError || snapshot.data == null) {
//             return const Center(child: Text("Error loading categories"));
//           }
//
//           final data = jsonDecode(snapshot.data!.body);
//           final List categories = data['docs'] ?? [];
//
//           if (categories.isEmpty) {
//             return const Center(child: Text("No categories found."));
//           }
//
//           return ListView.separated(
//             padding: const EdgeInsets.all(15),
//             itemCount: categories.length,
//             separatorBuilder: (context, index) => const Divider(),
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               final String categoryId = category['id'];
//               // Using 'name' based on your backend JSON structure
//               final String categoryName = category['name'] ?? "Unknown Category";
//
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
//                   child: const Icon(Icons.category_outlined, color: AppColors.primaryGreen),
//                 ),
//                 title: Text(
//                   categoryName,
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                 onTap: () async {
//                   // 1. Show the Loading Dialog
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (BuildContext dialogContext) {
//                       return const Center(
//                         child: CircularProgressIndicator(color: AppColors.primaryGreen),
//                       );
//                     },
//                   );
//
//                   try {
//                     // 2. Fetch the filtered products
//                     await Provider.of<ProductProvider>(context, listen: false)
//                         .fetchProductsByCategory(categoryId);
//
//                     // 3. SUCCESS NAVIGATION
//                     if (context.mounted) {
//                       // Close the Dialog FIRST
//                       Navigator.of(context, rootNavigator: true).pop();
//
//                       // Go back to the Home Screen (this avoids the history error)
//                       Navigator.pop(context);
//                     }
//                   } catch (e) {
//                     // 4. ERROR HANDLING
//                     if (context.mounted) {
//                       Navigator.of(context, rootNavigator: true).pop(); // Close dialog
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Failed to load category products")),
//                       );
//                     }
//                   }
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'category_products_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Text(
          "CATEGORIES",
          style: GoogleFonts.urbanist(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: http.get(Uri.parse('https://doma-backend.onrender.com/api/categories')),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Error loading categories"));
          }

          final data = jsonDecode(snapshot.data!.body);
          final List categories = data['docs'] ?? [];

          if (categories.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final String categoryId = category['id'];
              final String categoryName = category['name'] ?? "Unknown Category";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsScreen(
                        categoryId: categoryId,
                        categoryName: categoryName,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
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
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.category_outlined,
                          color: AppColors.primaryGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          categoryName,
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
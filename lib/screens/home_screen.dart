import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../constants.dart';
import '../data/dummy_data.dart'; // 1. Import your dummy data file here

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 2. We completely removed the 'final List products = [...]' line from here.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text("DOMA - Design & Buy"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Placeholder for Hero Slider
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                  child: Text("Promo Slider Here", style: TextStyle(color: Colors.white))
              ),
            ),

            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.builder(
                shrinkWrap: true, // Important: Allows GridView inside ScrollView
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dummyProducts.length, // 3. Use the imported list's length
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemBuilder: (context, index) {
                  // 4. Pass the item from your imported dummy list
                  return ProductCard(product: dummyProducts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
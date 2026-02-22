import 'package:flutter/material.dart';
import '../constants.dart';
import '../data/dummy_data.dart'; // Reusing your dummy categories

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text("All Categories"),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: dummyCategories.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: Icon(dummyCategories[index]['icon'], color: AppColors.primaryGreen),
            ),
            title: Text(
              dummyCategories[index]['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // Future: Navigate to a filtered product list
            },
          );
        },
      ),
    );
  }
}
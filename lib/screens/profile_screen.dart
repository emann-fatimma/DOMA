import 'package:flutter/material.dart';
import '../constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              color: AppColors.primaryGreen,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: AppColors.primaryGreen),
                  ),
                  SizedBox(height: 15),
                  Text("DOMA User", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("user@doma.com", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

            // Menu Options
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  _buildProfileOption(Icons.shopping_bag_outlined, "My Orders"),
                  _buildProfileOption(Icons.favorite_border, "Wishlist"),
                  _buildProfileOption(Icons.location_on_outlined, "Shipping Addresses"),
                  _buildProfileOption(Icons.payment, "Payment Methods"),
                  const Divider(height: 30),
                  _buildProfileOption(Icons.settings_outlined, "Settings"),
                  _buildProfileOption(Icons.help_outline, "Help & Support"),
                  _buildProfileOption(Icons.logout, "Log Out", isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for profile list tiles
  Widget _buildProfileOption(IconData icon, String title, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}

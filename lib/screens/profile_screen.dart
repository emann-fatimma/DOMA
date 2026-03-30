import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/auth_provider.dart';
import '../screens/edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the AuthProvider
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              color: AppColors.primaryGreen,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user?.name ?? "DOMA User",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? "user@doma.com",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Management
                  _buildProfileOption(
                    Icons.edit_note_rounded,
                    "Edit Profile Details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                  _buildProfileOption(Icons.shopping_bag_outlined, "My Orders"),
                  _buildProfileOption(Icons.favorite_border, "Wishlist"),

                  const Divider(height: 30),

                  // Dynamic Addresses Section
                  const Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    child: Text(
                        "My Addresses",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)
                    ),
                  ),

                  // Show list of addresses if they exist
                  if (user != null && user.addresses.isNotEmpty)
                    ...user.addresses.map((addr) => Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: AppColors.accentOrange),
                        title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${addr.street}, ${addr.city}"),
                        trailing: addr.isDefault
                            ? const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20)
                            : null,
                      ),
                    )).toList()
                  else
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text("No addresses saved yet.", style: TextStyle(color: Colors.grey,)),
                    ),

                  const Divider(height: 30),

                  // Settings & Logout
                  _buildProfileOption(Icons.settings_outlined, "Settings"),
                  _buildProfileOption(Icons.help_outline, "Help & Support"),
                  _buildProfileOption(
                    Icons.logout,
                    "Log Out",
                    isDestructive: true,
                    onTap: () {
                      context.read<AuthProvider>().logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
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
      onTap: onTap ?? () {},
    );
  }
}
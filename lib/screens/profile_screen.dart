import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../providers/auth_provider.dart';
import '../screens/edit_profile.dart';
import '../screens/my_orders_screen.dart';
import '../screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Inside _ProfileScreenState
  @override
  void initState() {
    super.initState();
    // 🔥 Force a refresh of the user data from the server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
    });
  }

  final ImagePicker _picker = ImagePicker();

  // 🔥 FUNCTION TO PICK AND UPLOAD IMAGE
  Future<void> _handleImageUpload() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512, // Resize for faster upload
      imageQuality: 75,
    );

    if (image != null) {
      // Show Loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final auth = context.read<AuthProvider>();
      final result = await auth.updateProfilePicture(image);

      if (!mounted) return;
      Navigator.pop(context); // Hide Loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    // Get the avatar URL from the user object (Depth 1 from profile endpoint)
    String? avatarUrl;
    if (user?.avatar != null && user?.avatar is Map) {
      avatarUrl = user?.avatar['url'];

      // If the URL is relative, attach your backend base URL
      if (avatarUrl != null && !avatarUrl.startsWith('http')) {
        avatarUrl = "https://doma-backend.onrender.com$avatarUrl";
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Text(
          "MY PROFILE",
          style: GoogleFonts.urbanist(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            color: Colors.white,
          ),
        ),
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
                  // 🔥 UPDATED AVATAR SECTION
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? const Icon(Icons.person, size: 44, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _handleImageUpload,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? "DOMA User",
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? "user@doma.com",
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  _buildProfileOption(
                    Icons.shopping_bag_outlined,
                    "My Orders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                      );
                    },
                  ),
                  _buildProfileOption(
                    Icons.favorite_border,
                    "Wishlist",
                    onTap: () {
                      Navigator.pushNamed(context, '/wishlist');
                    },
                  ),
                  if (!auth.isGoogleUser)
                    _buildProfileOption(
                      Icons.lock_outline,
                      "Change Password",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                        );
                      },
                    ),
                  const Divider(height: 30),

                  const Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    child: Text(
                        "My Addresses",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)
                    ),
                  ),

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
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4332).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFEF4444).withOpacity(0.08)
                    : AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? const Color(0xFFEF4444) : AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? const Color(0xFFEF4444) : AppColors.textDark,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
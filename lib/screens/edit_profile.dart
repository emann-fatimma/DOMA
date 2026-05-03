import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants.dart';
import '../models/user-model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  // We keep a local copy of addresses to edit before saving to the database
  List<Address> _tempAddresses = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phone);
    _tempAddresses = List.from(user?.addresses ?? []);
  }

  // Helper to show a dialog for adding a new address
  void _showAddAddressDialog() {
    final labelController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final zipController = TextEditingController(text: "54000"); // Default for testing

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Address"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: labelController, decoration: const InputDecoration(labelText: "Label (Home/Work)")),
              TextField(controller: streetController, decoration: const InputDecoration(labelText: "Street")),
              TextField(controller: cityController, decoration: const InputDecoration(labelText: "City")),
              TextField(controller: zipController, decoration: const InputDecoration(labelText: "Zip Code")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (streetController.text.isNotEmpty && cityController.text.isNotEmpty) {
                setState(() {
                  _tempAddresses.add(Address(
                    label: labelController.text.isEmpty ? "Address" : labelController.text,
                    street: streetController.text,
                    city: cityController.text,
                    zipCode: zipController.text,
                    country: "Pakistan", // Backend requirement
                    state: "Punjab",
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
  void _saveProfile() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updateFullProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      addresses: _tempAddresses, // Now sending the updated local list
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated!"), backgroundColor: AppColors.primaryGreen),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: AppColors.primaryGreen),
      body: SingleChildScrollView( // Changed to ScrollView because the list can get long
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Basic Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone Number", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Addresses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _showAddAddressDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add New"),
                )
              ],
            ),

            // Displaying current temporary addresses
            ..._tempAddresses.map((addr) => Card(
              child: ListTile(
                title: Text(addr.label),
                subtitle: Text("${addr.street}, ${addr.city}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _tempAddresses.remove(addr)),
                ),
              ),
            )),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
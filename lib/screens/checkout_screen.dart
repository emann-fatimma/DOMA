import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // UI State for selected payment method
  String _selectedPaymentMethod = 'COD'; // Defaults to Cash on Delivery

  // Text Controllers for the form
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the cart to show the total price
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. SHIPPING DETAILS
              // ==========================================
              const Text("Shipping Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Full Name", border: UnderlineInputBorder()),
                      validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Phone Number", border: UnderlineInputBorder()),
                      validator: (value) => value!.isEmpty ? "Please enter your phone number" : null,
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: "Street Address", border: UnderlineInputBorder()),
                      validator: (value) => value!.isEmpty ? "Please enter your address" : null,
                    ),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: "City", border: UnderlineInputBorder()),
                      validator: (value) => value!.isEmpty ? "Please enter your city" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ==========================================
              // 2. PAYMENT METHOD
              // ==========================================
              const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("Cash on Delivery (COD)", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Pay when your furniture arrives", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      activeColor: AppColors.accentOrange,
                      value: 'COD',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text("Credit / Debit Card", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Pay securely online", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      activeColor: AppColors.accentOrange,
                      value: 'CARD',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // ==========================================
      // 3. BOTTOM SUMMARY & CHECKOUT BUTTON
      // ==========================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount:", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                  // FIXED: Now uses totalAmount to match your CartProvider
                  Text(
                    "Rs. ${cartProvider.totalAmount}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Processing $_selectedPaymentMethod order for ${_nameController.text}..."),
                          backgroundColor: AppColors.accentOrange,
                        ),
                      );
                    }
                  },
                  child: const Text("Place Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
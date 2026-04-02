import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // UI State for selected payment method
  String _selectedPaymentMethod = 'COD';

  // Text Controllers for the form
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.user;

      if (user != null) {
        setState(() {
          _nameController.text = user.name;
          _phoneController.text = user.phone ?? "";

          if (user.addresses.isNotEmpty) {
            final defaultAddr = user.addresses.firstWhere(
                  (addr) => addr.isDefault,
              orElse: () => user.addresses.first,
            );
            _addressController.text = defaultAddr.street;
            _cityController.text = defaultAddr.city;
          }
        });
      }
    });
  }

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
    final cartProvider = Provider.of<CartProvider>(context);

    // --- Calculations for Backend & UI ---
    double subtotal = cartProvider.totalAmount;
    double shippingCost = 250.0; // Fixed delivery fee for furniture
    double tax = subtotal * 0.05; // 5% GST
    double totalAmount = subtotal + shippingCost + tax;

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
              // 1. ORDER SUMMARY
              const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartProvider.items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = cartProvider.items.values.toList()[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(item.product.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(item.product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text("Qty: ${item.quantity}"),
                      trailing: Text("Rs. ${item.product.price * item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // 2. SHIPPING DETAILS
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

              // 3. PAYMENT METHOD
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
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text("Credit / Debit Card", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Pay securely online", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      activeColor: AppColors.accentOrange,
                      value: 'CARD',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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
              // PRICE BREAKDOWN
              _buildPriceRow("Subtotal", "Rs. $subtotal"),
              _buildPriceRow("Shipping Fee", "Rs. $shippingCost"),
              _buildPriceRow("Tax (5%)", "Rs. ${tax.toStringAsFixed(2)}"),
              const Divider(),
              _buildPriceRow("Total Amount", "Rs. ${totalAmount.toStringAsFixed(2)}", isTotal: true),

              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      final cart = Provider.of<CartProvider>(context, listen: false);
                      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

                      final shippingData = {
                        'firstName': _nameController.text.split(' ').first,
                        'lastName': _nameController.text.contains(' ') ? _nameController.text.split(' ').last : '',
                        'street': _addressController.text,
                        'city': _cityController.text,
                        'state': 'Punjab',
                        'country': 'Pakistan',
                        'phone': _phoneController.text,
                      };

                      setState(() => _isLoading = true);

                      final result = await orderProvider.placeOrder(
                        shippingAddress: shippingData,
                        paymentMethod: _selectedPaymentMethod.toLowerCase(),
                        // Sending these ensures your Orders collection is perfectly filled
                        tax: tax,
                        shippingCost: shippingCost,
                      );

                      setState(() => _isLoading = false);

                      if (result['success']) {
                        cart.clearCartMemory();
                        // Refresh stock for DOMA products immediately
                        await Provider.of<ProductProvider>(context, listen: false).fetchProducts();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Success!",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        "Your furniture order has been placed.",
                                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.primaryGreen, // Matches your theme
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? "Checkout failed"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text("Place Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, color: isTotal ? Colors.black : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 22 : 14, fontWeight: FontWeight.bold, color: isTotal ? AppColors.accentOrange : Colors.black)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  const PaymentSuccessScreen({super.key, required this.orderId});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = Provider.of<CartProvider>(context, listen: false);
      cart.clearCartMemory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF1B5E20), size: 100),
                const SizedBox(height: 24),
                Text('Payment Successful!',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Order #${widget.orderId} has been confirmed.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home', (route) => false);
                  },
                  child: Text('Back to Home',
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/myOrders', (route) => false);
                  },
                  child: Text('View My Orders',
                      style: GoogleFonts.poppins(color: const Color(0xFF1B5E20))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentCancelScreen extends StatelessWidget {
  const PaymentCancelScreen({super.key});

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
                const Icon(Icons.cancel, color: Colors.red, size: 100),
                const SizedBox(height: 24),
                Text('Payment Cancelled',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Your payment was not completed.\nNo charges were made.',
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Try Again',
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home', (route) => false);
                  },
                  child: Text('Back to Home',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}